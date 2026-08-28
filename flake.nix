{
  description = "Nix packages for thou";

  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:X9yN6WSwyoFihH/tOriqxpaJEP3pd43z8UPmfipvoK8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    multiverse = {
      url = "github:fzakaria/nixpkgs-multiverse";
      flake = false;
    };
  };

  outputs = inputs: let
    systems = ["aarch64-linux" "x86_64-linux"];

    genAttrs = xs: f:
      builtins.listToAttrs (map (x: {
          name = x;
          value = f x;
        })
        xs);

    eachSystemArgs = genAttrs systems (system: let
      multiverse = import "${inputs.multiverse}/multiverse.nix" {
        inherit system;
        config.allowUnfree = true;
        fastFallback = "eval";
      };

      pkgs = multiverse.tip;

      pkgsNice = builtins.mapAttrs (name: value: value.eval) multiverse.fast.latest;
    in {
      inherit (pkgs) lib;
      inherit inputs multiverse pkgs pkgsNice system;
      nvfetcherSources = pkgs.callPackage ./_sources/generated.nix {};
    });

    forEachSystem = f: builtins.mapAttrs (_: args: f args) eachSystemArgs;
  in {
    devShells = forEachSystem ({
      pkgs,
      pkgsNice,
      system,
      ...
    }: {
      default = pkgs.mkShell {
        buildInputs =
          (with pkgsNice; [
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
      pkgsNice,
      ...
    }:
      (import nvfetcherSources.treefmt-nix.src).mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.alejandra = {
          enable = true;
          package = pkgsNice.alejandra;
        };
      });

    # Put cache here because yes
    legacyPackages = let
      mkCachePackage = system: packages:
        eachSystemArgs.${system}.pkgs.symlinkJoin {
          name = "cache-${system}";
          paths = packages;
        };
    in {
      aarch64-linux._cache = mkCachePackage "aarch64-linux" (with inputs.self.packages.aarch64-linux; [
        # helix-steel
        nvfetcher
      ]);

      x86_64-linux._cache = mkCachePackage "x86_64-linux" (with inputs.self.packages.x86_64-linux; [
        discord-rpc-lsp
        faugus-launcher
        # helix-steel
        helix-steel-attuned
        kitty-attuned
        lix-attuned
        mango-attuned
        mesa-attuned
        nixd-attuned
        noctalia-attuned
        nushell-attuned
        nvfetcher
        prismlauncher-cracked-unwrapped
        rust-analyzer-unwrapped-attuned
      ]);
    };

    nvfetcherSources = forEachSystem ({nvfetcherSources, ...}: nvfetcherSources);

    packages = forEachSystem (args:
      (import ./packages.nix args)
      // (import ./attuned-packages.nix args));
  };
}
