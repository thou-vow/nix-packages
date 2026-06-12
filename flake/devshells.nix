{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    devShells.default = pkgs.mkShell {
      buildInputs =
        (with pkgs; [
          alejandra
          taplo
          yamlfmt
        ])
        ++ (with self'.packages; [
          nvfetcher
        ]);
    };
  };
}
