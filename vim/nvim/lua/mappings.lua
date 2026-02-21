require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("i", "jk", "<ESC>")

-- Hsplit and vsplit with h/v
vim.api.nvim_set_keymap('n', 'v', ':NvimTreeVSplit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'h', ':NvimTreeHSplit<CR>', { noremap = true, silent = true })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
