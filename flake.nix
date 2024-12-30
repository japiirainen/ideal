{
  description = "`ideal` Computer Algebra System nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane.url = "github:ipetkov/crane";

    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      crane,
      flake-utils,
      rust-overlay,
      pre-commit-hooks,
      advisory-db,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        inherit (pkgs) lib;

        rustToolchainFor =
          p:
          p.rust-bin.stable.latest.default.override {
            targets = [ "wasm32-unknown-unknown" ];
          };
        craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchainFor;

        unfilteredRoot = ./.;
        src = lib.fileset.toSource {
          root = unfilteredRoot;
          fileset = lib.fileset.unions [
            (craneLib.fileset.commonCargoSources unfilteredRoot)
            (lib.fileset.fileFilter (
              file:
              lib.any file.hasExt [
                "html"
                "scss"
                "css"
              ]
            ) unfilteredRoot)
            (lib.fileset.maybeMissing ./assets)
          ];
        };

        commonArgs = {
          inherit src;
          strictDeps = true;

          buildInputs =
            [
            ]
            ++ lib.optionals pkgs.stdenv.isDarwin [
              pkgs.libiconv
            ];
        };

        nativeArgs = commonArgs // {
          pname = "ideal";
        };

        cargoArtifacts = craneLib.buildDepsOnly nativeArgs;

        ideal = craneLib.buildPackage (
          nativeArgs
          // {
            inherit cargoArtifacts;
          }
        );

        # Wasm packages
        wasmArgs = commonArgs // {
          pname = "website";
          cargoExtraArgs = "--package=website";
          CARGO_BUILD_TARGET = "wasm32-unknown-unknown";
        };

        cargoArtifactsWasm = craneLib.buildDepsOnly (
          wasmArgs
          // {
            doCheck = false;
          }
        );

        website = craneLib.buildTrunkPackage (
          wasmArgs
          // {
            pname = "website";
            cargoArtifacts = cargoArtifactsWasm;
            preBuild = ''
              cd ./website
            '';
            postBuild = ''
              mv ./dist ..
              cd ..
            '';
            wasm-bindgen-cli = pkgs.wasm-bindgen-cli.override {
              version = "0.2.99";
              hash = "sha256-1AN2E9t/lZhbXdVznhTcniy+7ZzlaEp/gwLEAucs6EA=";
              cargoHash = "sha256-DbwAh8RJtW38LJp+J9Ht8fAROK9OabaJ85D9C/Vkve4=";
            };
          }
        );

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            rustfmt.enable = true;
            deadnix.enable = true;
          };
        };
      in
      {
        checks = {
          inherit pre-commit-check;

          clippy = craneLib.cargoClippy (
            commonArgs
            // {
              inherit cargoArtifacts;
              cargoClippyExtraArgs = "--all-targets -- --deny warnings";
            }
          );

          cargo-doc = craneLib.cargoDoc (
            commonArgs
            // {
              inherit cargoArtifacts;
            }
          );

          my-crate-audit = craneLib.cargoAudit {
            inherit src advisory-db;
          };

          toml-fmt = craneLib.taploFmt {
            src = pkgs.lib.sources.sourceFilesBySuffices src [ ".toml" ];
          };
        };

        apps = {
          default = flake-utils.lib.mkApp {
            name = "ideal";
            drv = ideal;
          };

          website = flake-utils.lib.mkApp {
            name = "website";
            drv = website;
          };
        };

        packages = {
          inherit ideal website;
          default = ideal;
        };

        devShells.default = craneLib.devShell {
          checks = self.checks.${system};

          shellHook = ''
            export CLIENT_DIST=$PWD/website/dist;
          '';

          packages = with pkgs; [
            lld_18
            trunk
            clippy
            rust-analyzer
            rustfmt
            cargo
            rustc
            libffi
            taplo
          ];
        };
      }
    );
}
