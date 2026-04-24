{...}: {
  perSystem = {
    inputs',
    pkgs,
    system,
    ...
  }: {
    packages = let
      srcs = builtins.fromJSON ./srcs.json;
    in {
      brave = pkgs.brave.overrideAttrs (prevAttrs: {
        version = "";
        src = (builtins.mapAttrs (arch: args: pkgs.fetchurl args) srcs.brave).${system};
      });

      determinate-nix-direnv = pkgs.nix-direnv.override {
        nix = inputs'.determinate-nix.packages.default;
      };

      determinate-nix-fast-build = pkgs.nix-fast-build.override {
        nix-eval-jobs = inputs'.determinate-nix-eval-jobs.packages.default.overrideAttrs (finalAttrs: {
          # nix-fast-build in nixpkgs needs this
          passthru.nix = finalAttrs.passthru.nixComponents.nix-cli;
        });
      };

      determinate-nurl = pkgs.nurl.override {
        nix = inputs'.determinate-nix.packages.default;
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

      graalvm-oracle_21 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs (prevAttrs: {
        version = "21";
        src = (builtins.mapAttrs (arch: args: pkgs.fetchurl args) srcs.graalvm-oracle_21).${system};
        doCheck = false;
      });

      graalvm-oracle_25 = pkgs.graalvmPackages.graalvm-oracle.overrideAttrs (prevAttrs: {
        version = "25";
        src = (builtins.mapAttrs (arch: args: pkgs.fetchurl args) srcs.graalvm-oracle_25).${system};
        doCheck = false;
      });

      helix-steel = inputs'.helix-steel.packages.helix.overrideAttrs (prevAttrs: {
        cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [] ++ ["steel"];
      });
    };
  };
}
