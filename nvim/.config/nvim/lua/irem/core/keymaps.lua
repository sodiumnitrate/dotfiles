-- set leader key to space
vim.g.mapleader = " "

-- for conciseness
local keymap = vim.keymap

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- delete single char without copying into register
keymap.set("n", "x", "_x")

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")
