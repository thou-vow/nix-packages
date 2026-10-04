{
  inputs,
  lib,
  pkgs,
  system,
  ...
}: {
  brave = pkgs.brave.overrideAttrs {
    version = lib.removePrefix "v" (builtins.getAttr system {
      aarch64-linux = inputs._meta.brave-aarch64-linux.tag;
      x86_64-linux = inputs._meta.brave-x86-64-linux.tag;
    });
    src = builtins.getAttr system {
      aarch64-linux = inputs.brave-aarch64-linux;
      x86_64-linux = inputs.brave-x86-64-linux;
    };
  };

  discord-rpc-lsp = pkgs.callPackage ./pkgs/discord-rpc-lsp.nix {
    version = inputs._meta.discord-rpc-lsp.tag;
    src = inputs.discord-rpc-lsp;
  };

  dwproton = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "dwproton";
    version = lib.removePrefix "dwproton-" (builtins.getAttr system {
      x86_64-linux = inputs._meta.dwproton-x86-64-linux.tag;
    });
    src = builtins.getAttr system {
      x86_64-linux = inputs.dwproton-x86-64-linux;
    };
  };

  faugus-launcher = pkgs.callPackage ./pkgs/faugus-launcher.nix {
    version = inputs._meta.faugus-launcher.tag;
    src = inputs.faugus-launcher;
  };

  graalvm-oracle_21 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs {
    version = lib.removePrefix "Oracle GraalVM for JDK " (builtins.getAttr system {
      aarch64-linux = inputs._meta.graalvm-oracle-21-aarch64-linux.tag;
      x86_64-linux = inputs._meta.graalvm-oracle-21-x86-64-linux.tag;
    });
    src = builtins.getAttr system {
      aarch64-linux = inputs.graalvm-oracle-21-aarch64-linux;
      x86_64-linux = inputs.graalvm-oracle-21-x86-64-linux;
    };
    doInstallCheck = false;
  };

  graalvm-oracle_25 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs {
    version = lib.removePrefix "Oracle GraalVM " (builtins.getAttr system {
      aarch64-linux = inputs._meta.graalvm-oracle-25-aarch64-linux.tag;
      x86_64-linux = inputs._meta.graalvm-oracle-25-x86-64-linux.tag;
    });
    src = builtins.getAttr system {
      aarch64-linux = inputs.graalvm-oracle-25-aarch64-linux;
      x86_64-linux = inputs.graalvm-oracle-25-x86-64-linux;
    };
    doInstallCheck = false;
  };

  prismlauncher-cracked =
    (pkgs.prismlauncher.override {
      prismlauncher-unwrapped = inputs.self.packages.${system}.prismlauncher-cracked-unwrapped;
    }).overrideAttrs {
      version = inputs._meta.prismlauncher-cracked.tag;
      pname = "prismlauncher-cracked";
    };

  prismlauncher-cracked-unwrapped = pkgs.prismlauncher-unwrapped.overrideAttrs {
    pname = "prismlauncher-cracked-unwrapped";
    version = inputs._meta.prismlauncher-cracked.tag;
    src = inputs.prismlauncher-cracked;
  };

  proton-cachyos = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-cachyos-x86-64-linux.tag;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-cachyos-x86-64-linux;
    };
  };

  proton-cachyos-v3 = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton-v3";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-cachyos-x86-64-v3-linux.tag;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-cachyos-x86-64-v3-linux;
    };
  };

  proton-ge = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton-ge";
    version = lib.removePrefix "GE-Proton" (builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-ge-x86-64-linux.tag;
    });
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-ge-x86-64-linux;
    };
  };

  proton-wineland = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-wineland-x86-64-linux.tag;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-wineland-x86-64-linux;
    };
  };

  proton-wineland-v3 = pkgs.callPackage ./pkgs/proton-bin.nix {
    pname = "proton-v3";
    version = builtins.getAttr system {
      x86_64-linux = inputs._meta.proton-wineland-x86-64-v3-linux.tag;
    };
    src = builtins.getAttr system {
      x86_64-linux = inputs.proton-wineland-x86-64-v3-linux;
    };
  };
}
