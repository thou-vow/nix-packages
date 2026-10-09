{
  inputs,
  lib,
  pkgs,
  self,
  system,
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

      doCheck = false;
      doInstallCheck = false;
    });

  llvmLtoStdenv = pkgs.overrideCC pkgs.llvmPackages.stdenv (
    pkgs.llvmPackages.libstdcxxClang.override {
      bintools = pkgs.llvmPackages.bintools;
    }
  );
in {
  glfw-attuned =
    (pkgs.glfw.override {
      stdenv = llvmLtoStdenv;
      withMinecraftPatch = true;
    })
    .overrideAttrs (prevAttrs: {
      cmakeFlags =
        prevAttrs.cmakeFlags
        ++ [
          (lib.cmakeBool "CMAKE_INTERPROCEDURAL_OPTIMIZATION" true)
          (lib.cmakeBool "GLFW_BUILD_EXAMPLES" false)
          (lib.cmakeBool "GLFW_BUILD_TESTS" false)
          (lib.cmakeBool "GLFW_BUILD_X11" false)
          (lib.cmakeFeature "CMAKE_C_FLAGS" "-march=skylake")
        ];
    });

  kitty-attuned = pkgs.kitty.overrideAttrs (prevAttrs: {
    postPatch =
      prevAttrs.postPatch or ""
      + ''
        substituteInPlace setup.py \
          --replace-fail "native_optimizations and not sanitize" "not sanitize" \
          --replace-fail "-march=native -mtune=native" "-march=skylake -mtune=skylake" \
      '';

    doCheck = false;
    doInstallCheck = false;
  });

  lix-attuned = (pkgs.lix.override {stdenv = llvmLtoStdenv;}).overrideAttrs (prevAttrs: {
    mesonBuildType = "release";

    mesonFlags =
      prevAttrs.mesonFlags
      ++ [
        (lib.mesonOption "cpp_args" "-march=skylake")
        (lib.mesonBool "enable-tests" false)
      ];

    doCheck = false;
    doInstallCheck = false;
  });

  mango-attuned = (pkgs.mango.override {stdenv = llvmLtoStdenv;}).overrideAttrs (prevAttrs: {
    mesonBuildType = "release";

    mesonFlags =
      prevAttrs.mesonFlags
      ++ [
        (lib.mesonBool "b_lto" true)
        (lib.mesonOption "c_args" "-march=skylake")
      ];

    doCheck = false;
    doInstallCheck = false;
  });

  mesa-attuned =
    (pkgs.mesa.override {
      stdenv = llvmLtoStdenv;
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

      doCheck = false;
      doInstallCheck = false;
    });

  nixd-attuned = (pkgs.nixd.override {stdenv = llvmLtoStdenv;}).overrideAttrs (prevAttrs: {
    mesonBuildType = "release";

    mesonFlags =
      prevAttrs.mesonFlags or []
      ++ [
        (lib.mesonBool "b_lto" true)
        (lib.mesonOption "cpp_args" "-march=skylake")
      ];

    doCheck = false;
    doInstallCheck = false;
  });

  noctalia-attuned = (pkgs.noctalia.override {stdenv = llvmLtoStdenv;}).overrideAttrs (prevAttrs: {
    mesonFlags =
      prevAttrs.mesonFlags or []
      ++ [
        (lib.mesonBool "b_lto" true)
        (lib.mesonOption "c_args" "-march=skylake")
        (lib.mesonOption "cpp_args" "-march=skylake")
        (lib.mesonEnable "tests" false)
      ];
  });

  nushell-attuned = (attuneRust pkgs.nushell).overrideAttrs (prevAttrs: {
    env =
      prevAttrs.env
      // {
        RUSTFLAGS = toString [
          prevAttrs.env.RUSTFLAGS
          "-C opt-level=3"
        ];
      };

    postPatch =
      prevAttrs.postPatch or ""
      + ''
        substituteInPlace Cargo.toml \
          --replace-fail '"thin"' 'true'
      '';
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
  });

  llama-prism-attuned =
    (pkgs.callPackage "${inputs.llama-prism}/.devops/nix/package.nix" {
      stdenv = llvmLtoStdenv;
      useVulkan = true;
      useWebUi = true;
    }).overrideAttrs (prevAttrs: {
      __intentionallyOverridingVersion = true;
      version = inputs._meta.llama-prism.tag;

      cmakeFlags =
        prevAttrs.cmakeFlags
        ++ [
          (lib.cmakeFeature "CMAKE_C_FLAGS" "-march=skylake")
          (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-march=skylake")
          (lib.cmakeBool "CMAKE_INTERPROCEDURAL_OPTIMIZATION" true)
          (lib.cmakeBool "LLAMA_BUILD_TESTS" false)
          (lib.cmakeBool "LLAMA_BUILD_EXAMPLES" false)
        ];
    });

  rust-analyzer-attuned = pkgs.rust-analyzer.override {
    rust-analyzer-unwrapped = self.packages.${system}.rust-analyzer-unwrapped-attuned;
  };

  steelix-attuned = (attuneRust pkgs.steelix).overrideAttrs (prevAttrs: {
    env =
      prevAttrs.env or {}
      // {
        RUSTFLAGS = toString [
          "-C lto=fat"
          "-C opt-level=3"
        ];
      };
  });
}
