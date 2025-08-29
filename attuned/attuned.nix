inputs: system: let
  inherit (inputs) self chaotic niri;
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  lib = inputs.nixpkgs.lib;

  concatOptionalString = optional: others: lib.concatStringsSep " " (lib.optional (optional != "") optional ++ others);
in {
  helix-steel = self.legacyPackages.${system}.helix-steel.overrideAttrs (prevAttrs: {
    env =
      prevAttrs.env or {}
      // {
        RUSTFLAGS = concatOptionalString (prevAttrs.env.RUSTFLAGS or "") [
          "-C target-cpu=skylake"
          "-C opt-level=3"
          "-C lto=fat"
        ];
      };
  });

  linux-llvm = self.legacyPackages.${system}.linux-llvm.override {
    linux = chaotic.packages.${system}.linux_cachyos-lto;
    llvmPackages = pkgs.llvmPackages_latest;
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
    inherit (chaotic.packages.${system}.linux_cachyos-lto) features;
  };

  niri-unstable = niri.packages.${system}.niri-unstable.overrideAttrs (prevAttrs: {
    RUSTFLAGS =
      prevAttrs.RUSTFLAGS or []
      ++ [
        "-C target-cpu=skylake"
        "-C opt-level=3"
        "-C lto=fat"
      ];
  });

  nixd =
    (pkgs.nixd.override {inherit (pkgs.llvmPackages_latest) stdenv;}).overrideAttrs
    (prevAttrs: {
      env =
        prevAttrs.env or {}
        // {
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

  rust-analyzer-unwrapped = pkgs.rust-analyzer-unwrapped.overrideAttrs (prevAttrs: {
    env =
      prevAttrs.env or {}
      // {
        RUSTFLAGS = concatOptionalString (prevAttrs.env.RUSTFLAGS or "") [
          "-C target-cpu=skylake"
          "-C opt-level=3"
        ];
      };
  });

  xwayland-satellite-unstable = niri.packages.${system}.xwayland-satellite-unstable.overrideAttrs (prevAttrs: {
    RUSTFLAGS =
      prevAttrs.RUSTFLAGS or []
      ++ [
        "-C target-cpu=skylake"
        "-C opt-level=3"
      ];
  });
}
