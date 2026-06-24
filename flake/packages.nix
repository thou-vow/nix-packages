{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    nvfetcherSources,
    pkgs,
    self',
    system,
    ...
  }: {
    packages = {
      apple-emoji = pkgs.callPackage ../pkgs/apple-emoji.nix {
        inherit (nvfetcherSources.apple-emoji) version src;
      };

      brave = pkgs.brave.overrideAttrs {
        version = builtins.getAttr system {
          aarch64-linux = nvfetcherSources.brave-latest-aarch64-linux.version;
          x86_64-linux = nvfetcherSources.brave-latest-x64-linux.version;
        };
        src = builtins.getAttr system {
          aarch64-linux = nvfetcherSources.brave-latest-aarch64-linux.src;
          x86_64-linux = nvfetcherSources.brave-latest-x64-linux.src;
        };
      };

      discord-rpc-lsp = pkgs.callPackage ../pkgs/discord-rpc-lsp.nix {
        inherit (nvfetcherSources.discord-rpc-lsp) version src;
      };

      dwproton = pkgs.callPackage ../pkgs/proton-bin.nix {
        pname = "dwproton";
        version = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.dwproton-x64-linux.version;
        };
        src = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.dwproton-x64-linux.src;
        };
      };

      faugus-launcher = pkgs.callPackage ../pkgs/faugus-launcher.nix {
        inherit (nvfetcherSources.faugus-launcher) version src;
      };

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

      helix-steel =
        (pkgs.callPackage "${nvfetcherSources.helix-steel.src}/default.nix" {})
      .overrideAttrs (prevAttrs: {
          inherit (nvfetcherSources.helix-steel) version;
          cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
        });

      nvfetcher = pkgs.nvfetcher.overrideAttrs {
        inherit (nvfetcherSources.nvfetcher) version src;
      };

      prismlauncher-cracked =
        (pkgs.prismlauncher.override {
          prismlauncher-unwrapped = self'.packages.prismlauncher-cracked-unwrapped;
        }).overrideAttrs {
        inherit (nvfetcherSources.prismlauncher-cracked) version;
          pname = "prismlauncher-cracked";
        };

      prismlauncher-cracked-unwrapped = pkgs.prismlauncher-unwrapped.overrideAttrs {
        inherit (nvfetcherSources.prismlauncher-cracked) version src;
        pname = "prismlauncher-cracked-unwrapped";
      };

      proton-cachyos = pkgs.callPackage ../pkgs/proton-bin.nix {
        pname = "proton-cachyos";
        version = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-cachyos-x64-linux.version;
        };
        src = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-cachyos-x64-linux.src;
        };
      };

      proton-cachyos-v3 = pkgs.callPackage ../pkgs/proton-bin.nix {
        pname = "proton-cachyos-v3";
        version = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-cachyos-x64-linux-v3.version;
        };
        src = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-cachyos-x64-linux-v3.src;
        };
      };

      proton-ge = pkgs.callPackage ../pkgs/proton-bin.nix {
        pname = "proton-ge";
        version = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-ge-x64-linux.version;
        };
        src = builtins.getAttr system {
          x86_64-linux = nvfetcherSources.proton-ge-x64-linux.src;
        };
      };
    };
  };
}
