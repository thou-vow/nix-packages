{lib, ...}: {
  perSystem = {
    inputs',
    pkgs,
    self',
    ...
  }: {
    packages = {
      helix-steel-attuned = self'.legacyPackages.helix-steel.overrideAttrs (prevAttrs: {
        env =
          prevAttrs.env
          // {
            RUSTFLAGS =
              lib.optionalString (prevAttrs.env.RUSTFLAGS or "" != "") "${prevAttrs.env.RUSTFLAGS} "
              + toString [
                "-C target-cpu=skylake"
                "-C opt-level=3"
                "-C lto=fat"
              ];
          };
      });

      mesa-attuned =
        (pkgs.mesa.override {
          galliumDrivers = ["iris"];
          vulkanDrivers = ["intel"];
          vulkanLayers = ["overlay"];
          withValgrind = false;
        }).overrideAttrs (prevAttrs: {
          depsBuildBuild =
            lib.remove pkgs.buildPackages.stdenv.cc prevAttrs.depsBuildBuild
            ++ [pkgs.buildPackages.llvmPackages.clang];

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
              (lib.mesonEnable "gallium-va" false)
            ];

          outputs = ["out"];

          postInstall = "";
          postFixup = builtins.replaceStrings ["$opencl/lib/libRusticlOpenCL.so"] [""] prevAttrs.postFixup;
        });

      niri-unstable-attuned = inputs'.niri-flake.packages.niri-unstable.overrideAttrs (prevAttrs: {
        env =
          prevAttrs.env
          // {
            RUSTFLAGS =
              lib.optionalString (prevAttrs.env.RUSTFLAGS or "" != "") "${prevAttrs.env.RUSTFLAGS} "
              + toString [
                "-C lto=fat"
                "-C opt-level=3"
                "-C target-cpu=skylake"
              ];
          };

        doCheck = false;
      });

      nixd-attuned =
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

      rust-analyzer-unwrapped-attuned = pkgs.rust-analyzer-unwrapped.overrideAttrs (prevAttrs: {
        env =
          prevAttrs.env
          // {
            RUSTFLAGS =
              lib.optionalString (prevAttrs.env.RUSTFLAGS or "" != "") "${prevAttrs.env.RUSTFLAGS} "
              + toString [
                "-C embed-bitcode=yes" # It was disabled for some reason, we need to enable for LTO
                "-C lto=fat"
                "-C opt-level=3"
                "-C target-cpu=skylake"
              ];
          };
      });
    };
  };
}
