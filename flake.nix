{
  description = "Cached nix packages for thou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "github:DeterminateSystems/determinate";
    determinate-nix.follows = "determinate/nix";
    determinate-nix-eval-jobs = {
      url = "github:DeterminateSystems/nix-eval-jobs";
      inputs = {
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    helix-steel = {
      url = "github:mattwparas/helix/steel-event-system";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({
      lib,
      self,
      ...
    }: {
      imports = let
        isFlakeModule = file:
          file.hasExt "nix"
          && file.name != "flake.nix"
          && !lib.hasPrefix "_" file.name;
      in
        (./.
          |> lib.fileset.fileFilter isFlakeModule
          |> lib.fileset.toList)
        ++ [
          inputs.nix-wrapper-modules.flakeModules.default
        ];

      flake.checks = {
        x86_64-linux = {
          inherit
            (self.packages.x86_64-linux)
            determinate-nix-direnv
            determinate-nix-fast-build
            determinate-nurl
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
          buildInputs = with pkgs; [alejandra ruff yamlfmt];
        };

        formatter = inputs.treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            ruff-format.enable = true;
            yamlfmt.enable = true;
          };
        };
      };

      systems = ["aarch64-linux" "x86_64-linux"];
    });
}
