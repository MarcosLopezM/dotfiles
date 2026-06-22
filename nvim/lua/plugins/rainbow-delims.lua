return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local rainbow_delimiters = require("rainbow-delimiters")

    vim.g.rainbow_delimiters = {
      strategy = {
        [""] = rainbow_delimiters.strategy["global"],
        -- Pick the strategy for LaTeX dynamically based on the buffer size
        latex = function(bufnr)
          -- Disabled for very large files, global strategy for large files,
          -- local strategy otherwise
          local line_count = vim.api.nvim_buf_line_count(bufnr)
          if line_count > 10000 then
            return nil
          elseif line_count > 1000 then
            return "rainbow-delimiters.strategy.global"
          end
          return "rainbow-delimiters.strategy.local"
        end,
      },
      query = {
        [""] = "rainbow-delimiters",
        latex = "rainbow-blocks",
      },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterGreen",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterTeal",
        "RainbowDelimiterViolet",
        "RainbowDelimiterPink",
        "RainbowDelimiterLime",
      },
      -- blacklist = { "latex" },
    }

    -- Highlight colors
    vim.cmd([[
            hi RainbowDelimiterRed     guifg=#FF5555
            hi RainbowDelimiterGreen   guifg=#50FA7B
            hi RainbowDelimiterBlue    guifg=#6272A4
            hi RainbowDelimiterOrange  guifg=#FFAA00
            hi RainbowDelimiterTeal    guifg=#00CED1
            hi RainbowDelimiterViolet  guifg=#BD93F9
            hi RainbowDelimiterPink    guifg=#FF79C6
            hi RainbowDelimiterLime    guifg=#BFFF00
        ]])

    -- Enable rainbow in the current buffer immediately after plugin loads
    if vim.fn.exists(":RainbowDelimitersEnable") == 2 then
      vim.cmd("RainbowDelimitersEnable")
    end
  end,
}
