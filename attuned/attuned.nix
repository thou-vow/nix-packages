final: prev: inputs:
let
  lib = inputs.nixpkgs.lib;

  concatOptionalString =
    optional: others: lib.concatStringsSep " " (lib.optional (optional != "") optional ++ others);
in
{
  helix-steel = prev.helix.overrideAttrs (prevAttrs: {
    env = prevAttrs.env or { } // {
      RUSTFLAGS = concatOptionalString (prevAttrs.env.RUSTFLAGS or "") [
        "-C target-cpu=skylake"
        "-C opt-level=3"
        "-C lto=fat"
      ];
    };
  });

  linux-llvm = prev.linux-llvm.override {
    linux = final.linux_cachyos-lto;
    llvmPackages = final.llvmPackages_latest;
    suffix = "attuned";
    useO3 = true;
    mArch = "skylake";
    prependConfigValues = import ./kernel-localyesconfig.nix;
    withLTO = "thin";
    appendConfigValues = [
      "AUTOFDO_CLANG y"
      # "PROPELLER_CLANG y"

      # Unnecessary stuff uncaught by localyesconfig
      "DRM_XE n"
      "EXT4_FS n"
      "CRYPTO_LZO n"
      "LDM_PARTITION n"
      "KARMA_PARTITION n"
      "USB_UHCI_HCD n"
      "USB_OHCI_HCD n"
      "USB_EHCI_HCD n"
      "EXPERT y"
      "PROCESSOR_SELECT y"
      "X86_AMD_PLATFORM_DEVICE n"
      "X86_MCE_AMD n"
      "CPU_SUP_AMD n"
      "CPU_SUP_HYGON n"
      "CPU_SUP_CENTAUR n"
      "CPU_SUP_ZHAOXIN n"
      "AMD_NUMA n "
      "X86_AMD_PSTATE n"
      "PINCTRL_AMD n"
      "USB_PCI_AMD n"
      "AMD_3D_VCACHE n"
      "AMD_WBRF n"
      "AMD_IOMMU n"
      "XEN n"
      "KVM_XEN n"

      # For containers
      "VETH y"

      # Good for gaming
      "NTSYNC y"

      "SLUB_DEBUG n"
      "PM_DEBUG n"
      "WATCHDOG n"
      "CPU_MITIGATIONS n"
      "FORTIFY_SOURCE n"
    ];
    inherit (final.linux_cachyos) features;
  };

  niri-unstable = prev.niri-unstable.overrideAttrs (prevAttrs: {
    RUSTFLAGS = prevAttrs.RUSTFLAGS or [ ] ++ [
      "-C target-cpu=skylake"
      "-C opt-level=3"
      "-C lto=fat"
    ];
  });

  nixd =
    (prev.nixd.override { inherit (final.llvmPackages_latest) stdenv; }).overrideAttrs
      (prevAttrs: {
        env = prevAttrs.env or { } // {
          CFLAGS = concatOptionalString (prevAttrs.env.CFLAGS or "") [
            "-O3"
            "-march=skylake"
          ];
          CXXFLAGS = concatOptionalString (prevAttrs.env.CXXFLAGS or "") [
            "-O3"
            "-march=skylake"
          ];
        };
      });

  rust-analyzer-unwrapped = prev.rust-analyzer-unwrapped.overrideAttrs (prevAttrs: {
    env = prevAttrs.env or { } // {
      RUSTFLAGS = concatOptionalString (prevAttrs.env.RUSTFLAGS or "") [
        "-C target-cpu=skylake"
        "-C opt-level=3"
      ];
    };
  });

  xwayland-satellite-unstable = prev.xwayland-satellite-unstable.overrideAttrs (prevAttrs: {
    RUSTFLAGS = prevAttrs.RUSTFLAGS or [ ] ++ [
      "-C target-cpu=skylake"
      "-C opt-level=3"
    ];
  });
}
