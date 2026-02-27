return {
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        -- Don't auto-insert comment on new line
        padding = true,
        sticky = true,
      })
    vim.keymap.set("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", { desc = "Toggle line comment" })
    vim.keymap.set("v", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { desc = "Toggle line comment" })
    end,
  }
}
