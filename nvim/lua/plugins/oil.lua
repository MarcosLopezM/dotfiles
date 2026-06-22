return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  lazy = false,
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      constrain_cursor = "name",
      skip_confirm_for_simple_edits = true,
      watch_for_changes = true,
      prompt_save_on_select_new_entry = true,

      columns = { "icon" },

      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["q"] = { "actions.close", mode = "n", desc = "Closes Oil buffer" },
      },

      view_options = {
        show_hidden = true,
      },

      win_options = {
        signcolumn = "yes:2", -- space for git signs
        spell = false,
      },

      float = {
        padding = 2,
        max_width = 0.7,
        max_height = 0.7,
        border = "rounded",
        win_options = {
          winblend = 10,
        },
      },

      preview_win = {
        border = "rounded",
        max_height = 0.9,
        min_height = { 5, 0.1 },
        height = nil,
        win_options = {
          winblend = 0,
        },
      },
    })

    -- Override default explorer
    vim.keymap.set("n", "<leader>e", "<cmd>Oil --float<CR>", { desc = "Oil Explorer" })
  end,
}
