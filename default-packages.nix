{
  perSystem = {
    inputs',
    pkgs,
    system,
    ...
  }: {
    packages = let
      sources = import ./_sources/generated.nix {
        inherit (pkgs) fetchurl fetchgit fetchFromGitHub dockerTools;
      };
    in {
      apple-emoji = pkgs.callPackage ({
        stdenvNoCC,
        lib,
      }:
        stdenvNoCC.mkDerivation {
          inherit (sources.apple-emoji) pname version src;

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
        }) {};

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
        inherit (sources.discord-rpc-lsp) pname version src;

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
