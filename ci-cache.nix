{system ? builtins.currentSystem}: let
  packages = (import ./.).outputs.packages;

  toCache = {
    aarch64-linux = {
      inherit
        (packages.aarch64-linux)
        helix-steel
        nvfetcher
        ;
    };
    x86_64-linux = {
      inherit
        (packages.x86_64-linux)
        determinate-nix-eval-jobs
        determinate-nix-fast-build
        discord-rpc-lsp
        helix-steel
        helix-steel-attuned
        mesa-attuned
        niri-attuned
        nixd-attuned
        nvfetcher
        rust-analyzer-unwrapped-attuned
        ;
    };
  };
in
  toCache.${system}
