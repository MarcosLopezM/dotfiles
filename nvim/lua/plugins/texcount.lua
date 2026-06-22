return {
  dir = "/home/castel-mlm/plugins/texcount.nvim",
  lazy = false,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tex",
      callback = function()
        require("texcount").setup()
      end,
    })
  end,
}
