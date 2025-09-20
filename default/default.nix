inputs: pkgs: {
  custom-linux = pkgs.callPackage ./custom-linux/custom-linux.nix {};

  # nixpkgs only has 17 and 23.
  graalvm-oracle_21 = let
    src = {
      "x86_64-linux" = pkgs.fetchurl {
        hash = "sha256-yANbPObkXxSBdSxrOBU7tKU+60d8U0XVvsXKRO0YoFY=";
        url = "https://download.oracle.com/graalvm/21/archive/graalvm-jdk-21.0.8_linux-x64_bin.tar.gz";
      };
    };
  in
    pkgs.graalvmPackages.graalvm-oracle.overrideAttrs (finalAttrs: {
      version = "21";
      src = src.${pkgs.system};
    });

  helix-steel = inputs.helix.packages.${pkgs.system}.helix.overrideAttrs (prevAttrs: {
    cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
  });
}
