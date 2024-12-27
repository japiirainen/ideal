{
  description = "Nix flake for `ideal`.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    ghc-wasm-meta.url = "gitlab:ghc/ghc-wasm-meta?host=gitlab.haskell.org";

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        overlay = _final: prev: {
          ideal = prev.callCabal2nix "ideal" ./. { };
        };

        haskellPackages = pkgs.haskellPackages.extend overlay;

        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            cabal-fmt.enable = true;
            nixfmt-rfc-style.enable = true;
            deadnix.enable = true;
          };
        };

        website = import ./website { inherit system inputs; };
      in
      {
        packages = {
          inherit pre-commit-check;
          default = haskellPackages.ideal;
          ideal = haskellPackages.ideal;
        };

        apps = {
          format = flake-utils.lib.mkApp {
            drv = pkgs.writeShellApplication {
              name = "ideal-format";
              runtimeInputs = [
                haskellPackages.ormolu
                haskellPackages.cabal-fmt
              ];
              text = ''
                export LANG="C.UTF-8"
                export dirs="src bin website/app website/src"
                # shellcheck disable=SC2046,SC2086
                ormolu -m inplace $(find $dirs -type f -name "*.hs" -o -name "*.hs-boot")
                cabal-fmt --inplace ideal.cabal website/website.cabal
              '';
            };
          };
        };

        devShells = {
          default = haskellPackages.shellFor {
            packages =
              p: with p; [
                ideal
              ];

            buildInputs = with haskellPackages; [
              cabal-install
              haskell-language-server
              hpack
              hlint
              cabal-fmt
              ormolu
              ghcid
            ];

            inherit (pre-commit-check) shellHook;
          };

          website = website.shell;
        };
      }
    );
}
