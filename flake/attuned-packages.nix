{lib, ...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: let
    attuneRust = package:
      package.overrideAttrs (prevAttrs: {
        env =
          prevAttrs.env or {}
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
  in {
    packages = {
      helix-steel-attuned = attuneRust self'.packages.helix-steel;

      lix-attuned =
        (pkgs.lix.override {inherit (pkgs.llvmPackages_latest) stdenv;})
      .overrideAttrs (prevAttrs: {
          mesonBuildType = "release";

          mesonFlags =
            prevAttrs.mesonFlags ++ [
              (lib.mesonOption "cpp_args" "-march=skylake")
              (lib.mesonBool "enable-tests" false)
            ];
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

      niri-attuned = attuneRust pkgs.niri;

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
            ];
        });

      rust-analyzer-unwrapped-attuned = (attuneRust pkgs.rust-analyzer-unwrapped).overrideAttrs (prevAttrs: {
        env =
          prevAttrs.env
          // {
            RUSTFLAGS = toString [
              prevAttrs.env.RUSTFLAGS
              "-C embed-bitcode=yes" # Was implicitly disabled (?), needed for LTO
            ];
          };
        doCheck = false;
      });
    };
  };
}
