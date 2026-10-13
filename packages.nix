{
  inputs,
  lib,
  pkgs,
  self,
  system,
  ...
}: {
  discord-rpc-lsp = pkgs.callPackage ./pkgs/discord-rpc-lsp.nix {
    version = inputs._meta.discord-rpc-lsp.version;
    src = inputs.discord-rpc-lsp;
  };

  dwproton = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "dwproton";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.dwproton-x86-64-linux.version;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.dwproton-x86-64-linux;
    };
  };

  faugus-launcher = pkgs.faugus-launcher.overrideAttrs {
    version = inputs._meta.faugus-launcher.version;
    src = inputs.faugus-launcher;
  };

  graalvm-oracle_21 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs {
    version = lib.removePrefix "Oracle GraalVM for JDK " (builtins.getAttr system {
      aarch64-linux = inputs._meta.graalvm-oracle-21-aarch64-linux.version;
      x86_64-linux = inputs._meta.graalvm-oracle-21-x86-64-linux.version;
    });
    src = builtins.getAttr system {
      aarch64-linux = inputs.graalvm-oracle-21-aarch64-linux;
      x86_64-linux = inputs.graalvm-oracle-21-x86-64-linux;
    };
    doInstallCheck = false;
  };

  graalvm-oracle_25 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs {
    version = builtins.getAttr system {
      aarch64-linux = inputs._meta.graalvm-oracle-25-aarch64-linux.version;
      x86_64-linux = inputs._meta.graalvm-oracle-25-x86-64-linux.version;
    };
    src = builtins.getAttr system {
      aarch64-linux = inputs.graalvm-oracle-25-aarch64-linux;
      x86_64-linux = inputs.graalvm-oracle-25-x86-64-linux;
    };
    doInstallCheck = false;
  };

  prismlauncher-cracked =
    (pkgs.prismlauncher.override {
      prismlauncher-unwrapped = self.packages.${system}.prismlauncher-cracked-unwrapped;
    }).overrideAttrs {
      inherit (self.packages.${system}.prismlauncher-cracked-unwrapped) version;
      pname = "prismlauncher-cracked";
    };

  prismlauncher-cracked-unwrapped = pkgs.prismlauncher-unwrapped.overrideAttrs {
    pname = "prismlauncher-cracked-unwrapped";
    version = inputs._meta.prismlauncher-cracked.version;
    src = inputs.prismlauncher-cracked;
  };

  proton-cachyos = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton-cachyos";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-cachyos-x86-64-linux.version;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-cachyos-x86-64-linux;
    };
  };

  proton-cachyos-v3 = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton-cachyos-v3";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-cachyos-x86-64-v3-linux.version;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-cachyos-x86-64-v3-linux;
    };
  };

  proton-ge = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton-ge";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-ge-x86-64-linux.version;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-ge-x86-64-linux;
    };
  };

  proton-wineland = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton-wineland";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-wineland-x86-64-linux.version;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-wineland-x86-64-linux;
    };
  };

  proton-wineland-v3 = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton-wineland-v3";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-wineland-x86-64-v3-linux.version;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-wineland-x86-64-v3-linux;
    };
  };

  semeru-jre-bin-25 = pkgs.semeru-jre-bin-21.overrideAttrs {
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.semeru-jre-bin-25-x86-64-linux.version;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.semeru-jre-bin-25-x86-64-linux;
    };
    srcs = [];
  };
}
