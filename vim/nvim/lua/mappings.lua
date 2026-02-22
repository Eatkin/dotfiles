require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("i", "jk", "<ESC>")

local map = vim.keymap.set
local api = require("nvim-tree.api")

map("n", "<leader>uh", function()
  api.tree.toggle_gitignore_filter()
  api.tree.toggle_hidden_filter()
end, { desc = "Toggle hidden/gitignored (nvim-tree)" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
