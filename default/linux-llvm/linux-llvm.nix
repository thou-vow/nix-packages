{
  bash,
  callPackage,
  lib,
  linux,
  linuxManualConfig,
  llvmPackages,
  patchelf,
  pkgsBuildBuild,
  overrideCC,
  writeShellScriptBin,
  suffix ? "",
  patches ? [],
  useO3 ? false,
  mArch ? "",
  prependConfigValues ? [],
  withLTO ? "",
  appendConfigValues ? [],
  features ? {},
  verbose ? false,
  ...
}: let
  stdenvLLVM = let
    noBintools = {
      bootBintools = null;
      bootBintoolsNoLibc = null;
    };
    hostLLVM = llvmPackages.override noBintools;
    buildLLVM = llvmPackages.override noBintools;

    mkLLVMPlatform = platform:
      platform
      // {
        linux-kernel =
          platform.linux-kernel
          // {
            makeFlags =
              (platform.linux-kernel.makeFlags or [])
              ++ [
                "LLVM=1"
                "LLVM_IAS=1"
                "CC=${buildLLVM.clangUseLLVM}/bin/clang"
                "LD=${buildLLVM.lld}/bin/ld.lld"
                "HOSTLD=${hostLLVM.lld}/bin/ld.lld"
                "AR=${buildLLVM.llvm}/bin/llvm-ar"
                "HOSTAR=${hostLLVM.llvm}/bin/llvm-ar"
                "NM=${buildLLVM.llvm}/bin/llvm-nm"
                "STRIP=${buildLLVM.llvm}/bin/llvm-strip"
                "OBJCOPY=${buildLLVM.llvm}/bin/llvm-objcopy"
                "OBJDUMP=${buildLLVM.llvm}/bin/llvm-objdump"
                "READELF=${buildLLVM.llvm}/bin/llvm-readelf"
                "HOSTCC=${hostLLVM.clangUseLLVM}/bin/clang"
                "HOSTCXX=${hostLLVM.clangUseLLVM}/bin/clang++"
              ]
              ++ (lib.optionals (mArch != "") [
                "KCFLAGS+=-march=${mArch}"
                "KRUSTFLAGS+=-Ctarget-cpu=${mArch}"
              ])
              ++ (lib.optionals useO3 [
                "KCFLAGS+=-O3"
                "KRUSTFLAGS+=-Copt-level=3"
              ])
              ++ (lib.optionals verbose [
                "V=1"
              ]);
          };
      };

    stdenv' = overrideCC hostLLVM.stdenv hostLLVM.clangUseLLVM;
  in
    stdenv'.override (old: {
      hostPlatform = mkLLVMPlatform old.hostPlatform;
      buildPlatform = mkLLVMPlatform old.buildPlatform;
      extraNativeBuildInputs = [
        hostLLVM.lld
        patchelf
      ];
    });

  configfile = callPackage ./configfile.nix {
    inherit linux suffix patches prependConfigValues withLTO appendConfigValues;
    stdenv = stdenvLLVM;
  };

  kernel = linuxManualConfig {
    inherit (linux) src version;
    inherit configfile features;
    modDirVersion = "${linux.version}-${suffix}";

    kernelPatches =
      linux.kernelPatches
      ++ (builtins.map (file: {
          name = builtins.baseNameOf file;
          patch = file;
        })
        patches);

    stdenv = stdenvLLVM;

    allowImportFromDerivation = true;

    extraMeta = {
      description = "Easily-customizable Linux built with LLVM";
      broken = !stdenvLLVM.isx86_64;
    };
  };

  # You can generate values to pass to prependConfigValues following these steps:
  # ```
  # nix develop /etc/nixos#nixosConfigurations.nixos.boot.kernelPackages.kernel.configEnv
  # unpackPhase
  # cd $sourceRoot
  # patchPhase
  # make LLVM=1 LLVM_IAS=1 localyesconfig
  # scripts/diffconfig -m | diff-to-nix
  # ```
  configEnv = let
    diff-to-nix = writeShellScriptBin "diff-to-nix" ''
      #!${bash}
      exec > "prepend-config-values.nix"

      echo "["
      while IFS= read -r line; do
        if [[ $line == \#* ]] && [[ $line =~ CONFIG_([A-Za-z0-9_]+) ]]; then
          name=$${BASH_REMATCH[1]}
          echo "  \"$name n\""
        elif [[ $line == *"=y" ]]; then
          name=$${line#CONFIG_}
          name=$${name%=y}
          echo "  \"$name y\""
        elif [[ $line == *"=m" ]]; then
          name=$${line#CONFIG_}
          name=$${name%=m}
          echo "  \"$name m\""
        fi
      done
      echo "]"
    '';
  in
    configfile.overrideAttrs (prevAttrs: {
      depsBuildBuild =
        prevAttrs.depsBuildBuild or []
        ++ [diff-to-nix]
        ++ (with pkgsBuildBuild; [
          pkg-config
          ncurses
        ]);

      postPatch =
        prevAttrs.postPatch or ""
        + ''
          cp "${linux.configfile}" ".config"
        '';

      dontBuild = true;
      dontInstall = true;
    });
in
  kernel.overrideAttrs (prevAttrs: {
    postPatch =
      prevAttrs.postPatch
      + (lib.optionalString (suffix != "") ''
        sed -Ei"" 's/EXTRAVERSION = ?(.*)$/EXTRAVERSION = \1-${suffix}/g' Makefile
      '');

    passthru =
      prevAttrs.passthru or {}
      // {
        inherit configEnv features;
      };
  })
