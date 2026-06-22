return {
  {
    "nvim-mini/mini.ai",
    version = "*",
    config = function()
      local ai = require("mini.ai")

      ai.setup({
        custom_textobjects = {
          ["?"] = ai.gen_spec.pair("¿", "?"),
        },
      })
    end,
  },
  { "nvim-mini/mini.comment", version = "*", opts = {} },
  -- { "nvim-mini/mini.surround", version = "*", opts = {} },
  { "nvim-mini/mini.cursorword", version = "*", opts = {} },
  {
    "nvim-mini/mini.pairs",
    version = "*",
    config = function()
      local pairs = require("mini.pairs")
      pairs.setup({})

      local map_spanish = function()
        pairs.map_buf(0, "i", "¿", { action = "closeopen", pair = "¿?" })
        pairs.map_buf(0, "i", "¡", { action = "closeopen", pair = "¡!" })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "tex", "typst" },
        callback = map_spanish,
      })

      local map_typst = function()
        MiniPairs.map_buf(0, "i", "$", { action = "closeopen", pair = "$$" })
      end
      vim.api.nvim_create_autocmd("FileType", { pattern = "typst", callback = map_typst })
    end,
  },
  { "nvim-mini/mini.bufremove", version = "*", opts = {} },
}
