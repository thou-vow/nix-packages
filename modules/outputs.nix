{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.packages = let
    mkCachePackage = system: packages:
      (withSystem aarch64-linux ({pkgs, ...}: pkgs)).symlinkJoin {
        name = "cache-${system}";
        paths = packages;
      };
  in {
    aarch64-linux.cache = mkCachePackage "aarch64-linux" (with self.packages.aarch64-linux; [
      helix-steel
    ]);

    x86_64-linux.cache = mkCachePackage "x86_64-linux" (with self.packages.x86_64-linux; [
      discord-rpc-lsp
      helix-steel
      helix-steel-attuned
      mesa-attuned
      nixd-attuned
      rust-analyzer-unwrapped-attuned
    ]);
  };

  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
        nvfetcher
        taplo
        yamlfmt
      ];
    };

    formatter = inputs.treefmt-nix.lib.mkWrapper pkgs {
      projectRootFile = "flake.nix";
      programs = {
        alejandra.enable = true;
        taplo.enable = true;
        yamlfmt.enable = true;
      };
    };
  };

  systems = lib.systems.flakeExposed;
}
