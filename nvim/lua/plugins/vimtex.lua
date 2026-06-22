return {
  "lervag/vimtex",
  lazy = false,

  init = function()
    vim.g.vimtex_view_method = "general"
    vim.g.vimtex_view_general_viewer = "okular"
    vim.g.vimtex_view_general_options = "--unique file:@pdf#src:@line@tex"
    vim.g.vimtex_syntax_enabled = 1
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_doc_handlers = { "vimtex#doc#handlers#texdoc" }
    vim.g.vimtex_doc_confirm_single = 0
    vim.g.vimtex_syntax_conceal_cites = {
      type = "icon",
      icon = "📖",
      verbose = false,
    }
    vim.g.vimtex_delim_toggle_mod_list = {
      { "\\bigl", "\\bigr" },
      { "\\Bigl", "\\Bigr" },
      { "\\biggl", "\\biggr" },
      { "\\Biggl", "\\Biggr" },
    }
  end,

  config = function()
    vim.g.vimtex_compiler_latexmk = {
      out_dir = "build",
      continuous = 1,
      options = {
        "--shell-escape",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-file-line-error",
        "-cd",
      },
    }

    vim.g.vimtex_compiler_latexmk_engines = {
      _ = "-lualatex",
    }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tex",
      callback = function(event)
        vim.keymap.set("n", "<localleader>ld", "<plug>(vimtex-doc-package)", {
          desc = "Documentation for packages",
          silent = true,
        })
      end,
    })
  end,
}
