{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.packages = let
    mkCachePackage = system: packages:
      (withSystem system ({pkgs, ...}: pkgs)).symlinkJoin {
        name = "cache-${system}";
        paths = packages;
      };
  in {
    aarch64-linux.cache = mkCachePackage "aarch64-linux" (with self.packages.aarch64-linux; [
      helix-steel
      nvfetcher
    ]);

    x86_64-linux.cache = mkCachePackage "x86_64-linux" (with self.packages.x86_64-linux; [
      discord-rpc-lsp
      helix-steel
      helix-steel-attuned
      mesa-attuned
      niri-pr
      niri-pr-attuned
      nixd-attuned
      nvfetcher
      rust-analyzer-unwrapped-attuned
      vermouth
    ]);
  };

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    devShells.default = pkgs.mkShell {
      buildInputs =
        (with pkgs; [
          alejandra
          taplo
          yamlfmt
        ])
        ++ [
          self'.packages.nvfetcher
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
