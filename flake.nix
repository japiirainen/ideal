{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem =
        {
          self',
          config,
          pkgs,
          ...
        }:
        {
          haskellProjects.default = {
            packages = { };
            settings = { };

            devShell = {
              enable = true;

              tools = p: { cabal-fmt = p.cabal-fmt; };

              hlsCheck.enable = true;
            };

            autoWire = [
              "packages"
              "apps"
              "checks"
            ];
          };

          devShells.default = pkgs.mkShell {
            name = "my-haskell-package custom development shell";
            inputsFrom = [
              config.haskellProjects.default.outputs.devShell
            ];
            nativeBuildInputs = [ ];
          };
        };
    };
}
