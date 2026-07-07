{
  description = "Nix packages for thou";

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

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    chaotic-nyx = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs = {
        flake-schemas.follows = "";
        home-manager.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./flake/attuned-packages.nix
        ./flake/devshells.nix
        ./flake/formatter.nix
        ./flake/packages.nix
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        _module.args = {
          nvfetcherSources = pkgs.callPackage ./_sources/generated.nix {};

          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };

      systems = inputs.nixpkgs.lib.systems.flakeExposed;
    };
}
