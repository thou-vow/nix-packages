{
  description = "Cached nix packages for thou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    helix.url = "github:mattwparas/helix/steel-event-system";
    niri.url = "github:sodiboo/niri-flake";
  };

  nixConfig = {
    extra-substituters = ["https://thou-vow.cachix.org"];
    extra-trusted-public-keys = ["thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="];
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    systems = ["x86_64-linux" "aarch64-linux"];

    externalOverlays = [inputs.chaotic.overlays.default inputs.niri.overlays.niri];

    baseOverlays = externalOverlays ++ [self.overlays.default];
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
    overlays = {
      default = final: prev: import ./default/default.nix final prev inputs;
      attuned = final: prev: import ./attuned/attuned.nix final prev inputs;
    };

    # Packages to cache.
    checks = {
      "x86_64-linux" =
        {
          inherit
            (self.legacyPackages."x86_64-linux")
            helix-steel
            ;
        }
        # nix-fast-build doesn't support a list of derivations and neither recurses into sets.
        # That's why this set is flattened.
        // (lib.mapAttrs' (name: value: {
            name = "attunedPackages.${name}";
            inherit value;
          })
          self.legacyPackages."x86_64-linux".attunedPackages);
    };
    "aarch64-linux" = {
      inherit
        (self.legacyPackages."aarch64-linux")
        helix-steel
        ;
    };
  };
}
