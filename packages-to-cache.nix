{system ? builtins.currentSystem}: let
  self = builtins.getFlake (toString ./.);
  packages = {
    aarch64-linux = {
      inherit
        (self.packages.aarch64-linux)
        helix-steel
        ;
    };
    x86_64-linux = {
      inherit
        (self.packages.x86_64-linux)
        discord-rpc-lsp
        helix-steel
        helix-steel-attuned
        mesa-attuned
        nixd-attuned
        rust-analyzer-unwrapped-attuned
        ;
    };
  };
in self.packages.${system}
