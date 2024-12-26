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
            cabal-gild.enable = true;
            nixfmt-rfc-style.enable = true;
            deadnix.enable = true;
          };
        };

        website = import ./website { inherit system inputs; };
      in
      {
        packages.default = haskellPackages.ideal;
        packages.ideal = haskellPackages.ideal;

        devShells = {
          default = haskellPackages.shellFor {
            packages =
              p: with p; [
                ideal
              ];
            buildInputs =
              with haskellPackages;
              [
                cabal-install
                haskell-language-server
                hpack
                hlint
                cabal-fmt
                ormolu
                ghcid
              ]
              ++ (with pkgs; [
                treefmt
                nixfmt-rfc-style
              ]);

            inherit (pre-commit-check) shellHook;
          };

          website = website.shell;
        };
      }
    );
}
