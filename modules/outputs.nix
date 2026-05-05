{
  inputs,
  lib,
  self,
  ...
}: {
  flake.checks = {
    aarch64-linux = {
      inherit
        (self.packages.aarch64-linux)
        helix-steel
        ;
    };
    x86_64-linux = {
      inherit
        (self.packages.x86_64-linux)
        discord-rpc-lsp
        helix-steel
        helix-steel-attuned
        mesa-attuned
        nixd-attuned
        rust-analyzer-unwrapped-attuned
        ;
    };
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [alejandra nvfetcher taplo yamlfmt];
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
