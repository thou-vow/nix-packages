{
  description = "Cached nix packages for thou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nix-std.url = "github:chessai/nix-std";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    determinate-nix.follows = "determinate/nix";
    determinate-nix-eval-jobs.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    helix-steel = {
      url = "github:mattwparas/helix/steel-event-system";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake.url = "github:sodiboo/niri-flake";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nix-gaming-edge.url = "github:powerofthe69/nix-gaming-edge";
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
      withSystem,
      ...
    }: {
      imports = [
        (inputs.import-tree ./modules)
        inputs.wrapper-modules.flakeModules.wrappers
      ];

      flake.checks = let
        packagesToCache.x86_64-linux = withSystem "x86_64-linux" ({self', ...}:
          with self'.legacyPackages;
            [
              determinate-nix-direnv
              discord-rpc-lsp
              helix-steel
            ]
            ++ (with attunedPackages; [
              helix-steel
              mesa
              niri-unstable
              nixd
              rust-analyzer-unwrapped
              xwayland-satellite-unstable
            ]));
      in
        packagesToCache
        |> builtins.mapAttrs (
          _: list:
            list
            |> lib.imap0 (i: v: {
              name = "${v.name}-${toString i}";
              value = v;
            })
            |> builtins.listToAttrs 
        );

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
          buildInputs = with pkgs; [alejandra yamlfmt];
        };

        formatter = inputs.treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            yamlfmt.enable = true;
          };
        };

        wrappers.control_type = "build";
      };

      systems = ["aarch64-linux" "x86_64-linux"];
    });
}
