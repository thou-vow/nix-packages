{
  description = "Cached nix packages for thou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    helix.url = "github:mattwparas/helix/steel-event-system";
    niri.url = "github:sodiboo/niri-flake";
  };

  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  in {
    # Packages defined on this flake. Use with `nix build`, `nix run`, `nix shell`.
    legacyPackages = lib.genAttrs systems (system:
      import ./default/default.nix inputs system
      // {
        # The other package sets are made upon the default packages.
        attunedPackages = import ./attuned/attuned.nix inputs system;
      });

    # Packages to cache.
    checks = let
      derivationsToCache."x86_64-linux" =
        (with self.legacyPackages."x86_64-linux"; [
          helix-steel
        ])
        ++ (with self.legacyPackages."x86_64-linux".attunedPackages; [
          helix-steel
          linux-llvm
          linux-llvm.configfile
          niri-stable
          nixd
          rust-analyzer-unwrapped
          xwayland-satellite-stable
        ]);

      # Since nix-fast-build only support sets, we need this to repeat a package.
      derivationListToAttrs = list:
        builtins.listToAttrs (builtins.map (derivation: {
            # The name should be unique (I attempted drvPath before but got an error)
            name =
              builtins.hashString "sha256" (builtins.toJSON derivation)
              + "-${derivation.name}";
            value = derivation;
          })
          list);
    in {
      "x86_64-linux" = derivationListToAttrs derivationsToCache."x86_64-linux";
    };
  };
}
