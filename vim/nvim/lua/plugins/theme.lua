return {
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    config = function()
      vim.opt.background = "dark"
    end,
    priority = 1000,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {},
  },
  {
    "miikanissi/modus-themes.nvim",
    priority = 1000,
  },
  {
    "maxmx03/fluoromachine.nvim",
    priority = 1000,
    config = function()
      local fm = require "fluoromachine"

      fm.setup {
        glow = true,
        theme = "fluoromachine",
        transparent = true,
      }
    end,
  },
  {
    "lunarvim/templeos.nvim",
    priority = 1000,
  },
}
