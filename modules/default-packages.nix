{withSystem, ...}: {
  perSystem = {
    inputs',
    pkgs,
    system,
    ...
  }: {
    legacyPackages = {
      determinate-nix-direnv = pkgs.nix-direnv.override {
        nix = inputs'.determinate-nix.packages.default;
      };

      determinate-nix-fast-build = pkgs.nix-fast-build.override {
        nix-eval-jobs = withSystem system ({inputs', ...}:
          inputs'.determinate-nix-eval-jobs.packages.default.overrideAttrs (finalAttrs: {
            # nix-fast-build in nixpkgs needs this
            passthru.nix = finalAttrs.passthru.nixComponents.nix-cli;
          }));
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
        patches = [../assets/discord-rpc-lsp-go-mod-tidy.patch];

        vendorHash = "sha256-C0rXfMGK4P9KA7QhKEkvr4qIWZt3bewjRX3Qh5fwlsk=";
      });

      graalvm-oracle_21 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs (prevAttrs: {
        version = "21";
        src =
          {
            "x86_64-linux" = pkgs.fetchurl {
              url = "https://download.oracle.com/graalvm/21/archive/graalvm-jdk-21.0.9_linux-x64_bin.tar.gz";
              hash = "sha256-cLTSX7sxHZiLhsm2HleAKouWfbYW7mFyMMMYEnbkH3E=";
            };
          }.${
            system
          };
      });

      helix-steel = inputs'.helix-steel.packages.helix.overrideAttrs (prevAttrs: {
        cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
      });
    };
  };
}
