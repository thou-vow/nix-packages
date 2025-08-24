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

    systems = ["x86_64-linux"];

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
      import ./default/default.nix inputs pkgsBaseOverlays pkgsExternalOverlays
      // {
        # The other package sets are made upon the default packages.
        attunedPackages =
          import ./attuned/attuned.nix inputs (
            pkgsBaseOverlays.appendOverlays [self.overlays.attuned]
          )
          pkgsBaseOverlays;
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
      default = final: prev: recursivelyUpdatePackages prev (import ./default/default.nix inputs final prev);
      attuned = final: prev: recursivelyUpdatePackages prev (import ./attuned/attuned.nix inputs final prev);
    };
  };
}
