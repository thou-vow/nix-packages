{
  lib,
  linux,
  stdenv,
  writeText,
  suffix,
  patches,
  prependConfigValues,
  withLTO,
  appendConfigValues,
}: let
  transformConfigValue = raw: let
    split = lib.splitString " " raw;
    name = lib.elemAt split 0;
    value = lib.elemAt split 1;
  in "CONFIG_${name}=${value}";

  ltoArgs =
    if withLTO == "thin"
    then [
      "LTO_NONE n"
      "LTO_CLANG_FULL n"
      "LTO_CLANG_THIN y"
    ]
    else if withLTO == "full"
    then [
      "LTO_NONE n"
      "LTO_CLANG_FULL y"
      "LTO_CLANG_THIN n"
    ]
    else if withLTO == ""
    then [
      "LTO_NONE y"
      "LTO_CLANG_FULL n"
      "LTO_CLANG_THIN n"
    ]
    else throw "Unsupported withLTO value (should be \"full\", \"thin\" or \"\")";

  valuesToMerge = lib.map transformConfigValue (
    prependConfigValues
    ++ ltoArgs
    ++ appendConfigValues
  );

  customConfigFragment =
    writeText "linux-custom-config-fragment" (lib.concatStringsSep "\n" valuesToMerge);
in
  stdenv.mkDerivation {
    inherit (linux) src;
    name = "linux-${lib.optionalString (suffix != "") "${suffix}-"}config";

    patches = (builtins.map (kernelPatch: kernelPatch.patch) linux.kernelPatches) ++ patches;

    nativeBuildInputs = linux.nativeBuildInputs ++ linux.buildInputs;

    buildPhase = ''
      cp "${linux.configfile}" ".config"
      patchShebangs scripts/kconfig/merge_config.sh
      LLVM=1 LLVM_IAS=1 scripts/kconfig/merge_config.sh -n .config ${customConfigFragment}
    '';

    installPhase = ''
      cp .config $out
    '';
  }
