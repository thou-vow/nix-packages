{
  lib,
  stdenvNoCC,
  version,
  src,
}:
stdenvNoCC.mkDerivation {
  inherit version src;
  pname = "apple-emoji";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -D -m644 $src $out/share/fonts/truetype/AppleColorEmoji-Linux.ttf
  '';

  meta = with lib; {
    homepage = "https://github.com/samuelngs/apple-emoji-linux";
    description = "Apple Color Emoji for Linux";
    license = licenses.asl20;
  };
}
