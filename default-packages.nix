{...}: {
  perSystem = {
    inputs',
    pkgs,
    system,
    ...
  }: {
    packages = {
      brave = pkgs.brave.overrideAttrs (prevAttrs: {
        version = "1.89.143";
        src =
          {
            x86_64-linux = {
              url = "https://github.com/brave/brave-browser/releases/download/v1.89.143/brave-browser_1.89.143_amd64.deb";
              hash = "sha256-PwicpQOZBlKGf5BbKS2w6vA5izUXfL20Ogv9JYDLu7U=";
            };
          }.${
            system
          }
          |> pkgs.fetchurl;
      });

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

      graalvm-oracle_21 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs (prevAttrs: {
        version = "21";
        src =
          {
            aarch64-linux = {
              url = "https://download.oracle.com/graalvm/21/archive/graalvm-jdk-21.0.11_linux-aarch64_bin.tar.gz";
              hash = "sha256-brO/340rOBm7PkUar8r5yhkuW+7u+3jyrMj3P9aqofI=";
            };
            x86_64-linux = {
              url = "https://download.oracle.com/graalvm/21/archive/graalvm-jdk-21.0.11_linux-x64_bin.tar.gz";
              hash = "sha256-xH0nUDkRbCKp+qMX/D1FPUHcY5dKnclt7zphMbHexOo=";
            };
          }.${
            system
          }
          |> pkgs.fetchurl;
        doCheck = false;
      });

      graalvm-oracle_25 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs (prevAttrs: {
        version = "25";
        src =
          {
          }.${
            system
          }
          |> pkgs.fetchurl;
        doCheck = false;
      });

      helix-steel = inputs'.helix-steel.packages.helix.overrideAttrs (prevAttrs: {
        cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
      });
    };
  };
}
