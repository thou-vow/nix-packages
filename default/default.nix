inputs: pkgs: {
  custom-linux = pkgs.callPackage ./custom-linux/custom-linux.nix {};

  discord-rpc-lsp = pkgs.buildGoModule (finalAttrs: {
    pname = "discord-rpc-lsp";
    version = "1.0.1";

    src = pkgs.fetchFromGitHub {
      owner = "zerootoad";
      repo = "discord-rpc-lsp";
      tag = "v${finalAttrs.version}";
      hash = "sha256-1Zw+F/EfYjHHU0AYlAHT7g1sbuJrHRtGp9E1u9EPW8E=";
    };

    # A reproducible build needs `go.sum`, which is missing in the source
    # Instuctions to generate this patch:
    #  git clone --branch <version> https://github.com/zerootoad/discord-rpc-lsp
    #  cd discord-rpc-lsp
    #  go mod tidy
    #  git add -A
    #  git diff --staged > discord-rpc-lsp-go-mod-tidy.patch
    patches = [./discord-rpc-lsp-go-mod-tidy.patch];

    vendorHash = "sha256-C0rXfMGK4P9KA7QhKEkvr4qIWZt3bewjRX3Qh5fwlsk=";
  });

  graalvm-oracle_21 = let
    src = {
      "x86_64-linux" = pkgs.fetchurl {
        url = "https://download.oracle.com/graalvm/21/archive/graalvm-jdk-21.0.9_linux-x64_bin.tar.gz";
        hash = "sha256-cLTSX7sxHZiLhsm2HleAKouWfbYW7mFyMMMYEnbkH3E=";
      };
    };
  in
    pkgs.graalvmPackages.graalvm-oracle.overrideAttrs (prevAttrs: {
      version = "21";
      src = src.${pkgs.system};
    });

  helix-steel = inputs.helix-steel.packages.${pkgs.system}.helix.overrideAttrs (prevAttrs: {
    cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
  });
}
