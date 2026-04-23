return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup {
        options = {
          numbers = "ordinal",
          show_buffer_close_icons = false,
          show_close_icon = false,
        },
      }

      vim.keymap.set("n", "<leader>tr", function()
        local name = vim.fn.input "Tab name: "
        if name ~= "" then
          vim.cmd("BufferLineTabRename " .. name)
        end
      end, { noremap = true, silent = true })
    end,
  },
  {
    "tiagovla/scope.nvim",
    config = function()
      require("scope").setup {}
    end,
  },
}
