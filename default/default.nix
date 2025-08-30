inputs: system: let
  inherit (inputs) helix;
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
in {
  # nixpkgs only has 17 and 23.
  graalvm-oracle_21 = let
    src = {
      "x86_64-linux" = pkgs-unstable.fetchurl {
        hash = "sha256-Z6yFh2tEAs4lO7zoXevRrFFcZQUw7w7Stkx9dUB46CE=";
        url = "https://download.oracle.com/graalvm/21/archive/graalvm-jdk-21.0.7_linux-x64_bin.tar.gz";
      };
    };
  in
    pkgs-unstable.graalvmPackages.graalvm-oracle.overrideAttrs (finalAttrs: {
      version = "21";
      src = src.${system};
    });

  helix-steel = helix.packages.${system}.helix.overrideAttrs (prevAttrs: {
    cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
  });

  linux-llvm = pkgs-unstable.callPackage ./linux-llvm/linux-llvm.nix {};
}
