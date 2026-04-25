{lib, ...}: {
  flake.wrappers.eject = {
    config,
    pkgs,
    wlib,
    ...
  }: {
    imports = [wlib.modules.default];

    options.eject = {
      directory = lib.mkOption {
        type = lib.types.str;
        default = "\${WRAPPERS_EJECT_DIR:-$HOME/.eject}";
      };
      entries = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = {};
      };
    };

    config = {
      escapingFunction = wlib.escapeShellArgWithEnv;

      runShell =
        lib.mapAttrsToList (name: path: let
          entryEjectDir = "${config.eject.directory}/${baseNameOf path}";
        in {
          data =
            pkgs.writeScript "${name}-ejector"
            # sh
            ''
              #!${lib.getExe pkgs.dash}
              inputDir=${path}
              ejectDir=${entryEjectDir}
              if [ ! -d "$ejectDir" ]; then
                mkdir -p "$ejectDir" &&
                cp -RL "$inputDir"/. "$ejectDir"/ &&
                chmod -R u+w "$ejectDir"
              fi
            '';
        })
        config.eject.entries;
    };
  };
}
