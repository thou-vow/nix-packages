{
  bash,
  callPackage,
  lib,
  linux,
  linuxManualConfig,
  pkgsBuildBuild,
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
  inputs,
  ...
}: let
  extraMakeFlags =
    (lib.optionals (mArch != "") [
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

  configfile = callPackage ./configfile.nix {
    inherit linux suffix patches prependConfigValues withLTO appendConfigValues extraMakeFlags inputs;
  };

  kernel = linuxManualConfig {
    inherit (linux) src version;
    inherit configfile extraMakeFlags features;
    modDirVersion = "${linux.version}-${suffix}";

    kernelPatches =
      linux.kernelPatches
      ++ (builtins.map (file: {
          name = builtins.baseNameOf file;
          patch = file;
        })
        patches);

    extraMeta = {
      description = "Easily-customizable Linux built with LLVM";
      platforms = ["x86_64-linux"];
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
