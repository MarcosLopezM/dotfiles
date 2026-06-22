-- return {
--   "zenbones-theme/zenbones.nvim",
--   dependencies = {
--     "rktjmp/lush.nvim",
--   },
--   lazy = false,
--   priority = 1000,
--   config = function()
--     vim.g.duckbones_transparent_background = true
--     vim.cmd.colorscheme("duckbones")
--   end,
-- }

return {
  "uhs-robert/oasis.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("oasis").setup({
      style = "starlight",
      transparent = true,
    })
    vim.cmd.colorscheme("oasis")
  end,
}
