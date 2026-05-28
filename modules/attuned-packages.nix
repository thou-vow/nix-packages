{lib, ...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages = {
      helix-steel-attuned = self'.packages.helix-steel.overrideAttrs (prevAttrs: {
        env =
          prevAttrs.env
          // {
            RUSTFLAGS = toString (
              lib.optionals (prevAttrs.env.RUSTFLAGS or "" != "")
              [prevAttrs.env.RUSTFLAGS]
              ++ [
                "-C lto=fat"
                "-C opt-level=3"
                "-C target-cpu=skylake"
              ]
            );
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
              (lib.mesonBool "gallium-extra-hud" false)
              (lib.mesonBool "gallium-rusticl" false)
              (lib.mesonBool "install-mesa-clc" false)
              (lib.mesonBool "install-precomp-compiler" false)
              (lib.mesonBool "teflon" false)
              (lib.mesonEnable "intel-rt" false)
              (lib.mesonOption "tools" "")

              # Can't be enabled because required drivers are missing :)
              (lib.mesonEnable "gallium-va" false)
            ];

          outputs = ["out"];

          postInstall = "";
          postFixup = builtins.replaceStrings ["$opencl/lib/libRusticlOpenCL.so"] [""] prevAttrs.postFixup;
        });

      niri-pr-attuned = self'.packages.niri-pr.overrideAttrs (prevAttrs: {
        env =
          prevAttrs.env
          // {
            RUSTFLAGS = toString (
              lib.optionals (prevAttrs.env.RUSTFLAGS or "" != "")
              [prevAttrs.env.RUSTFLAGS]
              ++ [
                "-C lto=fat"
                "-C opt-level=3"
                "-C target-cpu=skylake"
              ]
            );
          };
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
            RUSTFLAGS = toString (
              lib.optionals (prevAttrs.env.RUSTFLAGS or "" != "")
              [prevAttrs.env.RUSTFLAGS]
              ++ [
                "-C embed-bitcode=yes" # Was implicitly disabled (?), needed for LTO
                "-C lto=fat"
                "-C opt-level=3"
                "-C target-cpu=skylake"
              ]
            );
          };
        doCheck = false;
      });
    };
  };
}
