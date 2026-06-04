{
  proton-ge-bin,
  pname,
  version,
  src,
}:
proton-ge-bin.overrideAttrs {
  inherit version src;
  pname = "proton-ge";

  preFixup = "";
}
