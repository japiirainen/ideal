{ system, inputs }:

let
  pkgs = inputs.ghc-wasm-meta.inputs.nixpkgs.legacyPackages.${system};
  watch = pkgs.writeScriptBin "watch" ''
    ${pkgs.watchexec}/bin/watchexec -w src -w app -w website.cabal ./build.sh
  '';
  serve = pkgs.writeScriptBin "serve" ''
    ${pkgs.miniserve}/bin/miniserve dist
  '';
in
{
  shell = pkgs.mkShell {
    packages = [
      inputs.ghc-wasm-meta.packages.${system}.all_9_10
      pkgs.esbuild
      pkgs.npm-check-updates
      pkgs.miniserve
      pkgs.wasmedge
      pkgs.wabt
      pkgs.watchexec
      watch
      serve
    ];
  };
}
