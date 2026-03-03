local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local previewers = require "telescope.previewers"
local Job = require "plenary.job"

local themes = require("themes.list").themes
table.sort(themes)

local function theme_previewer()
  return require("telescope.previewers").new_buffer_previewer {
    define_preview = function(self, entry, status)
      local theme = entry[1]

      -- Apply the theme temporarily
      vim.schedule(function()
        vim.cmd("colorscheme " .. theme)
      end)

      -- Show Python code in the preview window
      local python_lines = {
        "      ::::    ::: :::::::::: ::::::::  :::     ::: :::::::::::   :::   ::: ",
        "     :+:+:   :+: :+:       :+:    :+: :+:     :+:     :+:      :+:+: :+:+: ",
        "    :+:+:+  +:+ +:+       +:+    +:+ +:+     +:+     +:+     +:+ +:+:+ +:+ ",
        "   +#+ +:+ +#+ +#++:++#  +#+    +:+ +#+     +:+     +#+     +#+  +:+  +#+  ",
        "  +#+  +#+#+# +#+       +#+    +#+  +#+   +#+      +#+     +#+       +#+   ",
        " #+#   #+#+# #+#       #+#    #+#   #+#+#+#       #+#     #+#       #+#    ",
        "###    #### ########## ########      ###     ########### ###       ###     ",
      }
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, python_lines)
    end,
  }
end

M.select_theme = function(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = "Themes",
      finder = finders.new_table { results = themes },
      sorter = conf.generic_sorter(opts),
      previewer = theme_previewer(),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local theme = selection[1]
          vim.cmd("colorscheme " .. theme)
          local path = vim.fn.stdpath "data" .. "/last_theme"
          vim.fn.writefile({ theme }, path)
        end)
        return true
      end,
    })
    :find()
end


vim.keymap.set("n", "<leader>th", M.select_theme, { desc = "Select theme" })

return M
