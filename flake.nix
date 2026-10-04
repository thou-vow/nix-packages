{
  description = "Nix packages for thou";

  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://cache.manic.systems"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:X9yN6WSwyoFihH/tOriqxpaJEP3pd43z8UPmfipvoK8="
      "cache.manic.systems-1:s6OZanN8Us8vRi0jVivP3qlMn0cYHBjBALKrNe5nH8s="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = preInputs: let
    inputs =
      (import ./.tack) {
        overrides = preInputs.tackOverrides or {};
      }
      // {inherit (preInputs) self;};

    systems = ["aarch64-linux" "x86_64-linux"];

    genAttrs = xs: f:
      builtins.listToAttrs (map (x: {
          name = x;
          value = f x;
        })
        xs);

    eachSystemArgs = genAttrs systems (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      inherit (pkgs) lib;
      inherit inputs pkgs system;
    });

    forEachSystem = f: builtins.mapAttrs (_: args: f args) eachSystemArgs;
  in {
    inherit inputs;

    devShells = forEachSystem ({
      pkgs,
      system,
      ...
    }: {
      default = pkgs.mkShell {
        buildInputs =
          [
            inputs.tack.packages.${system}.tack
          ]
          ++ (with pkgs; [
            alejandra
            taplo
            nixd
          ]);
      };
    });

    formatter = forEachSystem ({pkgs, ...}:
      (import inputs.treefmt-nix).mkWrapper pkgs {
        projectRootFile = "flake.nix";
        programs.alejandra.enable = true;
      });

    # Put cache here because yes
    legacyPackages = let
      mkCachePackage = system: packages:
        eachSystemArgs.${system}.pkgs.symlinkJoin {
          name = "cache-${system}";
          paths = packages;
        };
    in {
      # aarch64-linux._cache = mkCachePackage "aarch64-linux" (with inputs.self.packages.aarch64-linux; [
      # ]);

      x86_64-linux._cache = mkCachePackage "x86_64-linux" (with inputs.self.packages.x86_64-linux; [
        discord-rpc-lsp
        faugus-launcher
        glfw-attuned
        kitty-attuned
        lix-attuned
        llama-prism-attuned
        mango-attuned
        mesa-attuned
        nixd-attuned
        noctalia-attuned
        nushell-attuned
        prismlauncher-cracked-unwrapped
        rust-analyzer-unwrapped-attuned
        steelix-attuned
      ]);
    };

    packages = forEachSystem (args:
      (import ./packages.nix args)
      // (import ./attuned-packages.nix args));
  };
}
