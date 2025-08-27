{
  description = "Cached nix packages for thou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

    externalOverlays = [
      inputs.chaotic.overlays.default
      inputs.niri.overlays.niri
    ];

    baseOverlays =
      externalOverlays
      ++ [
        self.overlays.default
      ];
  in {
    # Packages defined on this flake. Use with `nix build`, `nix run`, `nix shell`.
    legacyPackages = lib.genAttrs systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsExternalOverlays = pkgs.appendOverlays externalOverlays;
      pkgsBaseOverlays = pkgs.appendOverlays baseOverlays;
    in
      # I use an overlay interface for convenience (I like it).
      import ./default/default.nix pkgsBaseOverlays pkgsExternalOverlays inputs
      // {
        # The other package sets are made upon the default packages.
        attunedPackages =
          import ./attuned/attuned.nix
          (pkgsBaseOverlays.appendOverlays [self.overlays.attuned])
          pkgsBaseOverlays
          inputs;
      });

    # Overlays based on the packages defined on this flake.
    overlays = let
      # Package sets of this flake aren't updated versions of previously defined sets
      # Which means they aren't like `linuxPackages = prev.linuxPackages // { ... };`.
      # So, we update the previously defined sets here.
      recursivelyUpdatePackages = originalAttrs: newAttrs:
        lib.mapAttrs (name: value:
          if lib.isDerivation value
          then value
          else originalAttrs.${name} // recursivelyUpdatePackages originalAttrs.${name} value)
        newAttrs;
    in {
      default = final: prev: recursivelyUpdatePackages prev (import ./default/default.nix final prev inputs);
      attuned = final: prev: recursivelyUpdatePackages prev (import ./attuned/attuned.nix final prev inputs);
    };

    # Packages to cache.
    checks = let
      derivationsToCache."x86_64-linux" =
        (with self.legacyPackages."x86_64-linux"; [
          helix-steel
        ])
        ++ (with self.legacyPackages."x86_64-linux".attunedPackages; [
          helix-steel
          linux-llvm
          niri-unstable
          nixd
          rust-analyzer-unwrapped
          xwayland-satellite-unstable
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
