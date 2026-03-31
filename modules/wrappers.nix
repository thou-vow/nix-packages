{
  inputs,
  lib,
  ...
}: {
  flake.wrappers = {
    atuin = {
      config,
      pkgs,
      wlib,
      ...
    }: {
      imports = [wlib.modules.default];

      options.settings = lib.mkOption {
        type = (pkgs.formats.toml {}).type;
        default = {};
        description = ''
          Configuration of atuin.
          See <https://docs.atuin.sh/configuration/config/> for the full list of options.
        '';
      };

      config = {
        constructFiles.generatedConfig = {
          content = inputs.nix-std.lib.serde.toTOML config.settings;
          relPath = "config.toml";
        };

        env."ATUIN_CONFIG_DIR" = dirOf config.constructFiles.generatedConfig.path;

        package = lib.mkDefault pkgs.atuin;
      };
    };

    # fish = {
    #   config,
    #   pkgs,
    #   wlib,
    #   ...
    # }: {
    #   imports = [wlib.modules.default];

    #   config = {
    #     flags = {
    #       "--no-config" = true;
    #       # "-C" = "source ${fishConfig}";
    #     };
    #   };
    # };
  };
}
