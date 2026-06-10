{
  inputs,
  lib,
  ...
}: let
  flake-compat = import "${inputs.flake-parts}/vendor/flake-compat";
in {
  perSystem = {
    nvfetcherSources,
    pkgs,
    self',
    system,
    ...
  }: let
    flakes = {
      determinate-nix-eval-jobs = flake-compat {inherit (nvfetcherSources.determinate-nix-eval-jobs) src;};
    };
  in {
    packages = {
      apple-emoji = pkgs.callPackage ../pkgs/apple-emoji.nix {
        inherit (nvfetcherSources.apple-emoji) version src;
      };

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

      determinate-nix-fast-build =
        (pkgs.callPackage "${nvfetcherSources.nix-fast-build.src}/default.nix" {})
      .override {
          nix-eval-jobs = self'.packages.determinate-nix-eval-jobs;
        };

      determinate-nix-eval-jobs =
        flakes.determinate-nix-eval-jobs.outputs.packages.${system}.default.overrideAttrs
        (prevAttrs: {
          passthru.nix = prevAttrs.passthru.nixComponents.nix-cli;
        });

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

      faugus-launcher = pkgs.faugus-launcher.overrideAttrs {
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
