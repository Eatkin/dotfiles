local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

-- Window navigation with Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Cycle buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous buffer" })
-- Close current buffer
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { desc = "Close buffer" })

-- Tabs
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab / workspace" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab / workspace" })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { desc = "Keep only this tab" })

-- Open new lines without going into insert
-- <leader>of is oil so <leader>o is super slow
vim.keymap.set("n", "<leader>oo", "o<Esc>", { desc = "Open line below, stay normal" })
vim.keymap.set("n", "<leader>O", "O<Esc>", { desc = "Open line above, stay normal" })
