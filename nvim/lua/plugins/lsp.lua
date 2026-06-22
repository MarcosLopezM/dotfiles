return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ltex_plus = {
        on_attach = function(client, _)
          -- Get the specific diagnostic namespace for this LSP client
          local ns = vim.lsp.diagnostic.get_namespace(client.id)
          -- Disable virtual text and signs for this namespace only
          vim.diagnostic.config({ virtual_text = false, signs = false }, ns)
        end,
        settings = {
          cmd = { "ltex-ls-plus" },
          language = "en-US",
          motherTongue = "es",
          ltex = {
            checkFrequency = "save",
          },
        },
      },
      astro = {},
      tinymist = {
        single_file_support = true,
      },
    },
  },
}
