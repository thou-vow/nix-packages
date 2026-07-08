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
        discord-rpc-lsp
        faugus-launcher
        # helix-steel
        helix-steel-attuned
        kitty-attuned
        linux_cachyos-lto-v3
        lix-attuned
        # mango
        mango-attuned
        mesa-attuned
        nixd-attuned
        nushell-attuned
        nvfetcher
        prismlauncher-cracked-unwrapped
        rust-analyzer-unwrapped-attuned
        ;
    };
  };
in
  toCache.${system}
