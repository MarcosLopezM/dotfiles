return {
  "stevearc/conform.nvim",
  opts = function()
    local opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        tex = { "tex-fmt" },
        -- tex = { "latexindent" },
        bib = { "bibtex-tidy" },
        css = { "prettier" },
        bash = { "shfmt" },
        python = { "isort", "ruff" },
        yaml = { "yamlfmt" },
        astro = { "prettier" },
        typst = { "typstyle" },
        javascript = { "prettier" },
        json = { "prettier" },
        typescript = { "prettier" },
        markdown = { "prettier_md" },
        ["markdown.mdx"] = { "prettier" },
        sql = { "sqlfmt" },
      },
      formatters = {
        ["tex-fmt"] = {
          command = "tex-fmt",
          stdin = true,
          args = { "--tabsize=4", "--format-tables", "--wraplen=88", "--stdin" },
        },
        prettier_md = {
          command = "prettier",
          args = {
            "--stdin-filepath",
            "$FILENAME",
            "--prose-wrap",
            "always",
            "--print-width",
            "88",
          },
        },
      },
    }
    return opts
  end,
}
