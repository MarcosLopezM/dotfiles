return {
  "saghen/blink.cmp",
  dependencies = { "Kaiser-Yang/blink-cmp-dictionary" },
  opts = {
    fuzzy = { implementation = "prefer_rust_with_warning" },
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "dictionary" },
      providers = {
        dictionary = {
          module = "blink-cmp-dictionary",
          name = "Dict",
        },
      },
    },
  },
}
