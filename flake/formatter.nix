{...}: {
  perSystem = {
    nvfetcherSources,
    pkgs,
    self',
    ...
  }: {
    formatter = (import nvfetcherSources.treefmt-nix.src).mkWrapper pkgs {
      projectRootFile = "flake.nix";
      programs = {
        alejandra.enable = true;
        taplo.enable = true;
        yamlfmt.enable = true;
      };
    };
  };
}
