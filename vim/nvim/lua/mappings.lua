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
-- Closes the current buffer but keeps the window and tab layout intact
vim.keymap.set("n", "<leader>x", function()
    local current_buf = vim.api.nvim_get_current_buf()
    -- Switch to the previous buffer in the list first
    vim.cmd("bprevious")
    -- Delete the buffer we were just on
    vim.cmd("confirm bdelete " .. current_buf)
end, { desc = "Close buffer" })

-- Tabs
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab / workspace" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab / workspace" })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { desc = "Keep only this tab" })

-- Open new lines without going into insert
-- <leader>of is oil so <leader>o is super slow
vim.keymap.set("n", "<leader>oo", "o<Esc>", { desc = "Open line below, stay normal" })
vim.keymap.set("n", "<leader>O", "O<Esc>", { desc = "Open line above, stay normal" })

-- Dump keymaps to file
vim.api.nvim_create_user_command("DumpKeymaps", function()
  local modes = { "n", "i", "v", "x", "s", "o", "t", "c" }
  local lines = {}

  for _, mode in ipairs(modes) do
    local maps = vim.api.nvim_get_keymap(mode)

    table.insert(lines, "==== MODE: " .. mode .. " ====")

    for _, m in ipairs(maps) do
      local lhs = m.lhs
      local rhs = m.rhs or ""
      local desc = m.desc or ""
      table.insert(lines, string.format("%-15s → %-30s %s", lhs, rhs, desc))
    end

    table.insert(lines, "")
  end

  local path = vim.fn.stdpath "config" .. "/keymaps_dump.txt"
  vim.fn.writefile(lines, path)
  print("Keymaps written to: " .. path)
end, {})
