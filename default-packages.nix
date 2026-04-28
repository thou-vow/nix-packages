{
  perSystem = {
    inputs',
    pkgs,
    system,
    ...
  }: {
    packages = let
      sources = import ./_sources/generated.nix;
    in {
      brave = pkgs.brave.overrideAttrs {
        version =
          {
            aarch64-linux = sources.brave-aarch64-linux.version;
            x86_64-linux = sources.brave-x64-linux.version;
          }.${
            system
          };
        src =
          {
            aarch64-linux = sources.brave-aarch64-linux.src;
            x86_64-linux = sources.brave-x64-linux.src;
          }.${
            system
          };
      };

      discord-rpc-lsp = pkgs.buildGoModule (finalAttrs: {
        pname = "discord-rpc-lsp";
        version = "1.0.1";

        src = pkgs.fetchFromGitHub {
          owner = "zerootoad";
          repo = "discord-rpc-lsp";
          tag = finalAttrs.version;
          hash = "sha256-1Zw+F/EfYjHHU0AYlAHT7g1sbuJrHRtGp9E1u9EPW8E=";
        };

        # A reproducible build needs `go.sum`, which is missing in the source
        # Instructions to generate this patch:
        #  git clone --branch <version> https://github.com/zerootoad/discord-rpc-lsp
        #  cd discord-rpc-lsp
        #  go mod tidy
        #  git add -A
        #  git diff --staged > discord-rpc-lsp-go-mod-tidy.patch
        patches = [./discord-rpc-lsp-go-mod-tidy.patch];

        vendorHash = "sha256-C0rXfMGK4P9KA7QhKEkvr4qIWZt3bewjRX3Qh5fwlsk=";
      });

      graalvm-oracle_21 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs {
        version =
          {
            aarch64-linux = sources.graalvm-oracle-21-aarch64-linux.version;
            x86_64-linux = sources.graalvm-oracle-21-x64-linux.version;
          }.${
            system
          };
        src =
          {
            aarch64-linux = sources.graalvm-oracle-21-aarch64-linux.src;
            x86_64-linux = sources.graalvm-oracle-21-x64-linux.src;
          }.${
            system
          };
        doCheck = false;
      };

      graalvm-oracle_25 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs {
        version =
          {
            aarch64-linux = sources.graalvm-oracle-25-aarch64-linux.version;
            x86_64-linux = sources.graalvm-oracle-25-x64-linux.version;
          }.${
            system
          };
        src =
          {
            aarch64-linux = sources.graalvm-oracle-25-aarch64-linux.src;
            x86_64-linux = sources.graalvm-oracle-25-x64-linux.src;
          }.${
            system
          };
        doCheck = false;
      };

      helix-steel = inputs'.helix-steel.packages.helix.overrideAttrs (prevAttrs: {
        cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
      });
    };
  };
}
