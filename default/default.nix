inputs: system: let
  nixpkgs = inputs.nixpkgs.legacyPackages.${system};

  helix = inputs.helix.packages.${system};
in {
  # nixpkgs only has 17 and 23.
  graalvm-oracle_21 = let
    src = {
      "x86_64-linux" = nixpkgs.fetchurl {
        hash = "sha256-Z6yFh2tEAs4lO7zoXevRrFFcZQUw7w7Stkx9dUB46CE=";
        url = "https://download.oracle.com/graalvm/21/archive/graalvm-jdk-21.0.7_linux-x64_bin.tar.gz";
      };
    };
  in
    nixpkgs.graalvmPackages.graalvm-oracle.overrideAttrs (finalAttrs: {
      version = "21";
      src = src.${system};
    });

  helix-steel = helix.helix.overrideAttrs (prevAttrs: {
    cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
  });

  linux-llvm = nixpkgs.callPackage ./linux-llvm/linux-llvm.nix {};
}
