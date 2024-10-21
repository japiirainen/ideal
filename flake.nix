{
  description = "Nix flake for `ideal`.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        overlay = final: prev: {
          ideal = prev.callCabal2nix "ideal" ./. { };
        };
        haskellPackages = pkgs.haskellPackages.extend overlay;
      in
      {
        packages.default = haskellPackages.ideal;
        packages.ideal = haskellPackages.ideal;

        devShells.default = haskellPackages.shellFor {
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
              fourmolu
              ghcid
            ]
            ++ (with pkgs; [
              treefmt
              nixfmt-rfc-style
            ]);
          shellHook = ''
            ${pkgs.cabal-install}/bin/cabal build all
          '';
        };
      }
    );
}
