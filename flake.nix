{
  description = "Cached nix packages for thou";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    helix-steel.url = "github:mattwparas/helix/steel-event-system";
    niri-flake.url = "github:sodiboo/niri-flake";

    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
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
    eachSystem = f: nixpkgs.lib.genAttrs (import inputs.systems) (system: f nixpkgs.legacyPackages.${system});
  in {
    formatter = eachSystem (pkgs:
      inputs.treefmt-nix.lib.mkWrapper pkgs {
        projectRootFile = "flake.nix";

        programs = {
          alejandra.enable = true; # Nix
          yamlfmt.enable = true;
        };
      });

    # Packages defined on this flake. Use with `nix build`, `nix run`, `nix shell`.
    legacyPackages = eachSystem (pkgs:
      import ./default/default.nix inputs pkgs
      // {
        # The other package sets are made upon the default packages.
        attunedPackages = import ./attuned/attuned.nix inputs pkgs;
      });

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [alejandra yamlfmt];
      };
    });

    # Packages to cache.
    checks = let
      packagesToCache = {
        x86_64-linux = with self.legacyPackages.x86_64-linux;
          [
            helix-steel
          ]
          ++ (with attunedPackages; [
            custom-linux
            custom-linux.configfile
            helix-steel
            lix
            mesa
            niri-stable
            nixd
            rust-analyzer-unwrapped
            xwayland-satellite-stable
          ]);
      };

      # nix-fast-build only support sets, but we have duplicated names on the list...
      derivationListToAttrs = list:
        builtins.listToAttrs (nixpkgs.lib.imap0 (i: drv: {
            name = "${drv.name}-${builtins.toString i}";
            value = drv;
          })
          list);
    in
      builtins.mapAttrs (_: packages: derivationListToAttrs packages) packagesToCache;
  };
}
