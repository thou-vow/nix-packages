{system ? builtins.currentSystem}: let
  flake = builtins.getFlake (toString ./.);

  packages = flake.outputs.packages;

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
        discord-rpc-lsp
        faugus-launcher
        # helix-steel
        helix-steel-attuned
        kitty-attuned
        lix-attuned
        mango-attuned
        mesa-attuned
        nixd-attuned
        noctalia-attuned
        nushell-attuned
        nvfetcher
        prismlauncher-cracked-unwrapped
        rust-analyzer-unwrapped-attuned
        ;
    };
  };
in
  toCache.${system}
