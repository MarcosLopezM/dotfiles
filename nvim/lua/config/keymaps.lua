--- Buffer navigation ===============================================================================
vim.keymap.set("n", "<S-h>", "<CMD>bprev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<CMD>bnext<CR>", { desc = "Next buffer" })

vim.keymap.set("n", "<leader>bn", "<CMD>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<CMD>bprev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<CMD>bdel<CR>", { desc = "Delete buffer" })

-- Quick switch to last edited file
vim.keymap.set("n", "<leader>bb", "<CMD>e # <CR>", { desc = "Switch to other buffer" })

--- Window navigation ===============================================================================
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to the window below" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to the window above" })

-- Splitting and resizing ===============================================================================
vim.keymap.set("n", "<leader>sv", "<Cmd>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<Cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Increase window width" })

-- Smart line movement ===============================================================================
vim.keymap.set("n", "<A-j>", "<CMD>execute 'move .+' . v:count1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<CMD>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", { desc = "Move line up" })

-- Indenting in VM ===============================================================================
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Yank whole file ===============================================================================
vim.keymap.set("n", "<leader>a", "<Cmd>%y+<CR>", { desc = "Yank all text" })

-- Select whole file ===============================================================================
vim.keymap.set("n", "<A-a>", "ggVG", { noremap = true, silent = true, desc = "Select all" })

-- Smart text editing ===============================================================================
-- Better paste (doesn't replace clipboard with deleted text)
vim.keymap.set("v", "p", '"_dP', { noremap = true, silent = true })

-- Search and navigation ===============================================================================

vim.keymap.set("n", "gl", "$", { desc = "Go to end of line" })
vim.keymap.set("n", "gh", "^", { desc = "Go to start of line" })

-- Utility shortcuts ===============================================================================
vim.keymap.set("n", "z0", "1z=", { desc = "Fix word under cursor" })
