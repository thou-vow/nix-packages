{
  buildGoModule,
  version,
  src,
}:
buildGoModule (finalAttrs: {
  inherit version src;
  pname = "discord-rpc-lsp";

  # A reproducible build needs `go.sum`, which is missing in the source
  # Instructions to generate this patch:
  #  git clone --branch <version> https://github.com/zerootoad/discord-rpc-lsp
  #  cd discord-rpc-lsp
  #  go mod tidy
  #  git add -A
  #  git diff --staged > discord-rpc-lsp-go-mod-tidy.patch
  patches = [./discord-rpc-lsp-go-mod-tidy.patch];

  vendorHash = "sha256-C0rXfMGK4P9KA7QhKEkvr4qIWZt3bewjRX3Qh5fwlsk=";
})
