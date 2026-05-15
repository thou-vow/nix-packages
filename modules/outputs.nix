{
  inputs,
  lib,
  self,
  ...
}: {
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
