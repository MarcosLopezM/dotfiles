return {
  "ibhagwan/fzf-lua",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  opts = {},

  ---@module "fzf-lua"
  ---@type fzf-lua.config|{}
  ---@diagnostics disable: missing-fields
  keys = {
    {
      "<leader>fh",
      function()
        require("fzf-lua").help_tags()
      end,
      desc = "Fzf help tags",
    },
    {
      "<leader>fx",
      function()
        require("fzf-lua").diagnostics_document()
      end,
      desc = "Fzf diagnostics document",
    },
  },
  ---@diagnostics enable: missing-fields
}
