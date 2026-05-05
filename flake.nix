{
  description = "Cached nix packages for thou";

  inputs = {
    determinate.url = "github:DeterminateSystems/determinate";
    determinate-nix.follows = "determinate/nix";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    helix-steel = {
      url = "github:mattwparas/helix/steel-event-system";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nyx-loner.url = "github:lonerOrz/nyx-loner";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = ["https://thou-vow.cachix.org"];
    extra-trusted-public-keys = ["thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="];
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({
      lib,
      self,
      ...
    }: {
      imports = [(inputs.import-tree.filterNot (lib.hasSuffix "flake.nix") ./.)];

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

      systems = ["aarch64-linux" "x86_64-linux"];
    });
}
