return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- options = {
  --   theme = "oasis",
  -- },
  opts = function(_, opts)
    local custom_theme = require("lualine.themes.oasis")

    custom_theme.normal.c.bg = "NONE"

    local modes = { "insert", "visual", "replace", "command", "inactive" }
    for _, mode in ipairs(modes) do
      if custom_theme[mode] and custom_theme[mode].c then
        custom_theme[mode].c.bg = "NONE"
      end
    end

    opts.options.theme = custom_theme
  end,
}
