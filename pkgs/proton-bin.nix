{
  proton-ge-bin,
  pname,
  version,
  src,
}:
proton-ge-bin.overrideAttrs {
  inherit pname version src;
  preFixup = "";
}
