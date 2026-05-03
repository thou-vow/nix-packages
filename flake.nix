{
  description = "Cached nix packages for thou";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-unstable&shallow=1";
    nixpkgs-stable.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-25.11&shallow=1";

    flake-parts = {
      url = "git+https://github.com/hercules-ci/flake-parts?shallow=1";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "git+https://github.com/vic/import-tree?shallow=1";
    treefmt-nix = {
      url = "git+https://github.com/numtide/treefmt-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "github:DeterminateSystems/determinate";
    determinate-nix.follows = "determinate/nix";
    helix-steel = {
      url = "git+https://github.com/mattwparas/helix?ref=steel-event-system&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nyx-loner.url = "git+https://github.com/lonerOrz/nyx-loner?shallow=1";
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
