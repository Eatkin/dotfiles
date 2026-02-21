return {
  "github/copilot.vim",
  event = "VeryLazy",  -- load after startup
  config = function()
    -- optional: keybindings for accepting/rejecting suggestions
    vim.g.copilot_no_tab_map = true -- we will remap manually
    vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
    vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Dismiss()', { expr = true, silent = true })
    vim.cmd([[imap <silent><script><expr> <C-L> copilot#Next()]])
    vim.cmd([[imap <silent><script><expr> <C-H> copilot#Previous()]])
  end,
}
