{withSystem, ...}: {
  flake.packages.x86_64-linux = let
    inherit
      (withSystem "x86_64-linux" (args: args))
      inputs'
      nvfetcherSources
      pkgs
      system
      ;
  in {
    dwproton = 
      (pkgs.proton-ge-bin.override {
        steamDisplayName = "DW-Proton";
      }).overrideAttrs {
        inherit (nvfetcherSources.dwproton-x64-linux) src version;
        pname = "dwproton";
      };

    proton-cachyos =
      (pkgs.proton-ge-bin.override {
        steamDisplayName = "Proton-CachyOS";
      }).overrideAttrs {
        inherit (nvfetcherSources.proton-cachyos-x64-linux) src version;
        pname = "proton-cachyos";
      };

    proton-cachyos-v3 =
      (pkgs.proton-ge-bin.override {
        steamDisplayName = "Proton-CachyOS v3";
      }).overrideAttrs {
        inherit (nvfetcherSources.proton-cachyos-x64-linux-v3) src version;
        pname = "proton-cachyos-v3";
      };
  };

  perSystem = {
    inputs',
    nvfetcherSources,
    pkgs,
    system,
    ...
  }: {
    packages = {
      apple-emoji = pkgs.callPackage ({
        stdenvNoCC,
        lib,
      }:
        stdenvNoCC.mkDerivation {
          inherit (nvfetcherSources.apple-emoji) pname version src;

          dontUnpack = true;
          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
            install -D -m644 $src $out/share/fonts/truetype/AppleColorEmoji-Linux.ttf
          '';

          meta = with lib; {
            homepage = "https://github.com/samuelngs/apple-emoji-linux";
            description = "Apple Color Emoji for Linux";
            license = licenses.asl20;
          };
        }) {};

      brave-latest = pkgs.brave.overrideAttrs {
        version = builtins.getAttr system {
          aarch64-linux = nvfetcherSources.brave-latest-aarch64-linux.version;
          x86_64-linux = nvfetcherSources.brave-latest-x64-linux.version;
        };
        src = builtins.getAttr system {
          aarch64-linux = nvfetcherSources.brave-latest-aarch64-linux.src;
          x86_64-linux = nvfetcherSources.brave-latest-x64-linux.src;
        };
      };

      discord-rpc-lsp = pkgs.buildGoModule (finalAttrs: {
        inherit (nvfetcherSources.discord-rpc-lsp) pname version src;

        # A reproducible build needs `go.sum`, which is missing in the source
        # Instructions to generate this patch:
        #  git clone --branch <version> https://github.com/zerootoad/discord-rpc-lsp
        #  cd discord-rpc-lsp
        #  go mod tidy
        #  git add -A
        #  git diff --staged > discord-rpc-lsp-go-mod-tidy.patch
        patches = [./discord-rpc-lsp-go-mod-tidy.patch];

        vendorHash = "sha256-C0rXfMGK4P9KA7QhKEkvr4qIWZt3bewjRX3Qh5fwlsk=";
      });

      graalvm-oracle_21 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs {
        version = builtins.getAttr system {
          aarch64-linux = nvfetcherSources.graalvm-oracle-21-aarch64-linux.version;
          x86_64-linux = nvfetcherSources.graalvm-oracle-21-x64-linux.version;
        };
        src = builtins.getAttr system {
          aarch64-linux = nvfetcherSources.graalvm-oracle-21-aarch64-linux.src;
          x86_64-linux = nvfetcherSources.graalvm-oracle-21-x64-linux.src;
        };
        doInstallCheck = false;
      };

      graalvm-oracle_25 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs {
        version = builtins.getAttr system {
          aarch64-linux = nvfetcherSources.graalvm-oracle-25-aarch64-linux.version;
          x86_64-linux = nvfetcherSources.graalvm-oracle-25-x64-linux.version;
        };
        src = builtins.getAttr system {
          aarch64-linux = nvfetcherSources.graalvm-oracle-25-aarch64-linux.src;
          x86_64-linux = nvfetcherSources.graalvm-oracle-25-x64-linux.src;
        };
        doInstallCheck = false;
      };

      helix-steel = inputs'.helix-steel.packages.helix.overrideAttrs (prevAttrs: {
        cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
      });

      niri-pr = inputs'.niri-pr.packages.niri;

      nvfetcher = inputs'.nvfetcher.packages.default;
    };
  };
}
