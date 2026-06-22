vim.o.number = true -- Line numbers
vim.o.relativenumber = true -- Relative line numbers
vim.o.cursorline = true -- Highlight current line
vim.o.scrolloff = 10 -- Keep 10 lines above/below cursor
vim.o.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
vim.o.wrap = true -- Wrap lines
vim.o.textwidth = 88 -- Text width
vim.o.spell = true
vim.opt.spelllang = { "en_us", "es" }
-- t: auto-wrap text
-- c: auto-wrap comments
-- r: inserte comment leader after enter
-- o: keep comment with o or O, and remove with C-U
-- q: allow comments formatting
-- w: Trailing white space == paragraph continues
-- j: smart comment leader removal
-- n: recognize numbered lists
vim.opt.formatoptions = "tcroqwjn]"
vim.o.tabstop = 4
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.smartindent = true
vim.o.autoindent = true

-- Search settings ===============================================================================
vim.o.smartcase = true -- Case sensitive if uppercase in search
vim.o.incsearch = true -- Show matches as you type

-- Visual settings ===============================================================================
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.showmatch = true -- Highlight matching brackets
vim.o.matchtime = 2
vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.pumheight = 10 -- Popup menu height
vim.o.pumblend = 10 -- Popup menu transparency
vim.o.winblend = 0 -- Floating window transparency
vim.o.conceallevel = 1

-- Performance settings ===============================================================================
vim.o.lazyredraw = false
vim.o.synmaxcol = 300 -- Syntax highlighting limit
vim.o.redrawtime = 10000
vim.o.maxmempattern = 20000
vim.o.updatetime = 300 -- Faster completion

-- File handling ===============================================================================
vim.o.backup = false -- Don't create backup files
vim.o.writebackup = false -- Don't creat backup before writing
vim.o.swapfile = false -- Don't create swap files
vim.o.undofile = true -- Persistent undo
vim.o.ttimeoutlen = 0 -- Key code timeout
vim.o.autoread = true -- Auto reload files changed outside nvim
vim.o.autowrite = false -- Auto save
-- Options settings for diff mode
vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.diffopt:append("linematch:60")

-- Undo directory and its subprocess
local undodir = "~/.local/share/nvim/undodir"
vim.o.undodir = vim.fn.expand(undodir)
local undodir_path = vim.fn.expand(undodir)
if vim.fn.isdirectory(undodir_path) == 0 then
  vim.fn.mkdir(undodir_path, "p")
end

-- Behavior settings ===============================================================================
vim.o.errorbells = false -- No error bells
vim.o.backspace = "indent,eol,start" -- Better backspace behavior
vim.o.autochdir = false -- Don't autochange directory
-- vim.opt.iskeyword:append("-") -- Treat dash as part of word
vim.opt.path:append("**") -- Include subdirectories in search
vim.o.selection = "inclusive" -- Selection behavior
vim.o.mouse = "a" -- Enable mouse support
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
vim.o.modifiable = true -- Allow buffer modifications
vim.o.encoding = "UTF-8" -- Set encoding

-- Command-line completion ===============================================================================
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wildignorecase = true

vim.opt.guicursor = {
  "n-v-c:block",
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "o:hor50",
}

-- Folding settings ===============================================================================
vim.o.grepprg = "rg --vimgrep"
vim.o.grepformat = "%f:%l:%c:%m" -- filename, line number, column, content
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99 -- Start with all folds open

-- Split behavior ===============================================================================
vim.o.splitbelow = true
vim.o.splitright = true

-- Local config files ===============================================================================
vim.o.exrc = true
vim.o.secure = true

-- Lazy picker ===============================================================================
vim.g.lazyvim_picker = "fzf"
