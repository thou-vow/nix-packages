inputs: pkgs: let
  inherit (inputs.nixpkgs) lib;

  self = inputs.self.legacyPackages.${pkgs.system};
  chaotic = inputs.chaotic.legacyPackages.${pkgs.system};
  niri-flake = inputs.niri-flake.packages.${pkgs.system};

  concatOptionalString = optional: others: lib.concatStringsSep " " (lib.optional (optional != "") optional ++ others);
in {
  custom-linux = self.custom-linux.override {
    linux = chaotic.linux_cachyos-lts;
    llvmPackages = pkgs.llvmPackages_latest;
    suffix = "attuned";
    useO3 = true;
    mArch = "skylake";
    prependConfigValues = import ./kernel-localyesconfig.nix;
    withLTO = "full";
    appendConfigValues = [
      # Unnecessary stuff uncaught by localyesconfig
      "NR_CPUS 2"
      "DRM_XE n"
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
      "X86_SGX n"

      # Not unnecessary but I'm not interested
      "DEBUG_INFO n"
      "DEBUG_INFO_DWARF5 n"
      "SLUB_DEBUG n"
      "PM_DEBUG n"
      "WATCHDOG n"
      "CPU_MITIGATIONS n"
      "FORTIFY_SOURCE n"

      # USB drive
      "EXFAT_FS y"

      # For containers and waydroid
      "EXT4_FS y"
      "BRIDGE y"
      "VETH y"
      "TUN y"
      "NF_NAT y"
      "IP_NF_FILTER y"
      "IP_NF_NAT y"
      "NETFILTER_XT_TARGET_CHECKSUM y"
      "NETFILTER_XT_TARGET_MASQUERADE y"
    ];
    preferBuiltinsOverModules = true;
    inherit (chaotic.linux_cachyos-lts) features;
  };

  helix-steel = self.helix-steel.overrideAttrs (prevAttrs: {
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

  lix =
    (pkgs.lixPackageSets.latest.lix.override {
      inherit (pkgs.llvmPackages_latest) stdenv;
    }).overrideAttrs (prevAttrs: {
      mesonBuildType = "release";

      mesonFlags =
        prevAttrs.mesonFlags
        ++ [
          (lib.mesonOption "cpp_args" "-march=skylake")
          (lib.mesonOption "rust_args" "-Ctarget-cpu=skylake")
        ];

      doInstallCheck = false;
    });

  mesa =
    (pkgs.mesa.override {
      inherit (pkgs.llvmPackages) stdenv;
      galliumDrivers = ["iris" "llvmpipe"];
      vulkanDrivers = ["intel"];
      vulkanLayers = ["overlay"];
      withValgrind = false;
    }).overrideAttrs (prevAttrs: {
      depsBuildBuild = lib.remove pkgs.buildPackages.stdenv.cc prevAttrs.depsBuildBuild ++ [
        pkgs.buildPackages.llvmPackages.clang
      ];

      mesonBuildType = "release";

      mesonFlags =
        prevAttrs.mesonFlags
        ++ [
          # (lib.mesonBool "b_lto" true)
          (lib.mesonOption "c_args" "-march=skylake")
          (lib.mesonOption "cpp_args" "-march=skylake")

          # Unnecessary stuff
          (lib.mesonBool "teflon" false)
          (lib.mesonBool "gallium-extra-hud" false)
          (lib.mesonBool "gallium-rusticl" false)
          (lib.mesonEnable "intel-rt" false)
          (lib.mesonOption "tools" "")
          (lib.mesonBool "install-mesa-clc" false)
          (lib.mesonBool "install-precomp-compiler" false)

          # Can't be enabled because required drivers are missing
          (lib.mesonEnable "gallium-vdpau" false)
          (lib.mesonEnable "gallium-va" false)
        ];

      outputs = ["out"];

      postInstall = "";
    });

  niri-stable = niri-flake.niri-stable.overrideAttrs (prevAttrs: {
    RUSTFLAGS =
      prevAttrs.RUSTFLAGS or []
      ++ [
        "-C lto=fat"
        "-C opt-level=3"
        "-C target-cpu=skylake"
      ];

    doCheck = false;
  });

  nixd =
    (pkgs.nixd.override {
      inherit (pkgs.llvmPackages_latest) stdenv;
    }).overrideAttrs
    (prevAttrs: {
      mesonFlags =
        prevAttrs.mesonFlags or []
        ++ [
          (lib.mesonBool "b_lto" true)
          (lib.mesonOption "cpp_args" "-march=skylake")
          (lib.mesonOption "rust_args" "-Ctarget-cpu=skylake")
        ];
    });

  rust-analyzer-unwrapped = pkgs.rust-analyzer-unwrapped.overrideAttrs (prevAttrs: {
    env =
      prevAttrs.env or {}
      // {
        RUSTFLAGS = concatOptionalString (prevAttrs.env.RUSTFLAGS or "") [
          "-C embed-bitcode=yes" # It's enabled for some reason, we need to disable for LTO
          "-C lto=fat"
          "-C opt-level=3"
          "-C target-cpu=skylake"
        ];
      };
  });

  xwayland-satellite-stable = niri-flake.xwayland-satellite-stable.overrideAttrs (prevAttrs: {
    RUSTFLAGS =
      prevAttrs.RUSTFLAGS or []
      ++ [
        "-C embed-bitcode=yes" # It's enabled for some reason, we need to disable for LTO
        "-C lto=fat"
        "-C opt-level=3"
        "-C target-cpu=skylake"
      ];
  });
}
