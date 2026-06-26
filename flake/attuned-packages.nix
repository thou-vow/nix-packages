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
            RUSTFLAGS = toString [
              (lib.optionals (prevAttrs.env.RUSTFLAGS or "" != "")
                prevAttrs.env.RUSTFLAGS)
              "-C target-cpu=skylake"
            ];
          };
      });
  in {
    packages = {
      helix-steel-attuned = attuneRust self'.packages.helix-steel;

      kitty-attuned = pkgs.kitty.overrideAttrs (prevAttrs: {
        postPatch =
          prevAttrs.postPatch or ""
          + ''
            substituteInPlace setup.py \
              --replace-fail "native_optimizations and not sanitize" "not sanitize" \
              --replace-fail "-march=native -mtune=native" "-march=skylake -mtune=skylake" \
          '';
      });

      lix-attuned =
        (pkgs.lix.override {inherit (pkgs.llvmPackages) stdenv;})
      .overrideAttrs (prevAttrs: {
          mesonBuildType = "release";

          mesonFlags =
            prevAttrs.mesonFlags
            ++ [
              (lib.mesonOption "cpp_args" "-march=skylake")
              (lib.mesonBool "enable-tests" false)
            ];
        });

      mangowc-attuned =
        (self'.packages.mangowc.override {
          inherit (pkgs.llvmPackages) stdenv;
        }).overrideAttrs (prevAttrs: {
          mesonFlags =
            prevAttrs.mesonFlags
            ++ [
              (lib.mesonOption "c_args" "-march=skylake")
            ];
        });

      mesa-attuned =
        (pkgs.mesa.override {
          inherit (pkgs.llvmPackages) stdenv;
          galliumDrivers = ["iris"];
          vulkanDrivers = ["intel"];
          vulkanLayers = ["overlay"];
          withValgrind = false;
        }).overrideAttrs (prevAttrs: {
          depsBuildBuild =
            lib.remove pkgs.buildPackages.stdenv.cc prevAttrs.depsBuildBuild
            ++ [pkgs.llvmPackages.bintools];

          mesonBuildType = "release";

          mesonFlags =
            prevAttrs.mesonFlags
            ++ [
              (lib.mesonBool "allow-broken-lto" true)
              (lib.mesonBool "b_lto" true)
              (lib.mesonOption "c_args" "-march=skylake")
              (lib.mesonOption "c_link_args" "-fuse-ld=lld")
              (lib.mesonOption "cpp_args" "-march=skylake")
              (lib.mesonOption "cpp_link_args" "-fuse-ld=lld")

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

      nixd-attuned =
        (pkgs.nixd.override {
          inherit (pkgs.llvmPackages) stdenv;
        }).overrideAttrs
        (prevAttrs: {
          mesonBuildType = "release";

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
              "-C lto=fat"
              "-C opt-level=3"
            ];
          };
        doCheck = false;
      });

      rust-analyzer-attuned = pkgs.rust-analyzer.override {
        rust-analyzer-unwrapped = self'.packages.rust-analyzer-unwrapped-attuned;
      };
    };
  };
}
