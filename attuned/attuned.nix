final: prev: inputs: let
  lib = inputs.nixpkgs.lib;

  concatOptionalString = optional: others:
    lib.concatStringsSep " " (lib.optional (optional != "") optional ++ others);
in {
  helix-steel = prev.helix.overrideAttrs (prevAttrs: {
    env =
      prevAttrs.env or {}
      // {
        RUSTFLAGS =
          concatOptionalString (prevAttrs.env.RUSTFLAGS or "")
          ["-C target-cpu=skylake" "-C opt-level=3" "-C lto=fat"];
      };
  });

  linux-llvm = prev.linux-llvm.override {
    linux = final.linux_cachyos-lto;
    llvmPackages = final.llvmPackages_latest;
    suffix = "attuned";
    useO3 = true;
    mArch = "skylake";
    prependStructuredConfig =
      (import ./kernel-localyesconfig.nix lib)
      // (with lib.kernel; {
        "AUTOFDO_CLANG" = yes;
        "PROPELLER_CLANG" = yes;

        # Unnecessary stuff not caught by localyesconfig
        "DRM_XE" = no;
        "KVM_AMD" = no;

        # For containers
        "VETH" = yes;

        # Good for gaming
        "NTSYNC" = yes;
      });
    withLTO = "full";
    disableDebug = false; # Keep debug for AutoFDO
    inherit (final.linux_cachyos) features;
  };

  niri-unstable = prev.niri-unstable.overrideAttrs (prevAttrs: {
    RUSTFLAGS =
      prevAttrs.RUSTFLAGS or []
      ++ [
        "-C target-cpu=skylake"
        "-C opt-level=3"
        "-C lto=fat"
      ];
  });

  nixd = (prev.nixd.override {inherit (final.llvmPackages_latest) stdenv;}).overrideAttrs (prevAttrs: {
    env =
      prevAttrs.env or {}
      // {
        CFLAGS = concatOptionalString (prevAttrs.env.CFLAGS or "") ["-O3" "-march=skylake"];
        CXXFLAGS = concatOptionalString (prevAttrs.env.CXXFLAGS or "") ["-O3" "-march=skylake"];
      };
  });

  rust-analyzer-unwrapped = prev.rust-analyzer-unwrapped.overrideAttrs (prevAttrs: {
    env =
      prevAttrs.env or {}
      // {
        RUSTFLAGS = concatOptionalString (prevAttrs.env.RUSTFLAGS or "") [
          "-C target-cpu=skylake"
          "-C opt-level=3"
        ];
      };
  });

  xwayland-satellite-unstable = prev.xwayland-satellite-unstable.overrideAttrs (prevAttrs: {
    RUSTFLAGS =
      prevAttrs.RUSTFLAGS or []
      ++ [
        "-C target-cpu=skylake"
        "-C opt-level=3"
      ];
  });
}
