{
  description = "Nix packages for thou";

  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:X9yN6WSwyoFihH/tOriqxpaJEP3pd43z8UPmfipvoK8="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;

    systems = lib.systems.flakeExposed;

    forEachSystem = f:
      lib.genAttrs systems (system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
        f {
          inherit inputs lib pkgs system;
          nvfetcherSources = pkgs.callPackage ./_sources/generated.nix {};
        });
  in {
    devShells = forEachSystem ({
      pkgs,
      system,
      ...
    }: {
      default = pkgs.mkShell {
        buildInputs =
          (with pkgs; [
            alejandra
          ])
          ++ (with inputs.self.packages.${system}; [
            nvfetcher
          ]);
      };
    });

    formatter = forEachSystem ({
      nvfetcherSources,
      pkgs,
      ...
    }:
      (import nvfetcherSources.treefmt-nix.src).mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.alejandra.enable = true;
      });

    nvfetcherSources = forEachSystem ({nvfetcherSources, ...}: nvfetcherSources);

    packages = forEachSystem (args:
      (import ./packages.nix args)
      // (import ./attuned-packages.nix args));
  };
}
