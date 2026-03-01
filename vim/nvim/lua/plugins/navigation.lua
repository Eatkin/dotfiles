return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },

    config = function()
      -- Sensible split behavior
      vim.opt.splitright = true
      vim.opt.splitbelow = true

      require("oil").setup {
        default_file_explorer = true,

        view_options = {
          show_hidden = false,
        },

        keymaps = {
          -- Directory navigation
          ["<Tab>"] = "actions.select",
          ["<S-Tab>"] = "actions.parent",
          ["-"] = "actions.parent",
          ["q"] = "actions.close",

          -- Open file
          ["<CR>"] = "actions.select",

          -- Splits
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-t>"] = { "actions.select", opts = { tab = true } },
        },
        float = {
          -- Padding around the floating window
          padding = 2,
          -- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          max_width = 0.5,
          max_height = 0.6,
          border = nil,
          win_options = {
            winblend = 0,
          },
          -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
          get_win_title = nil,
          -- preview_split: Split direction: "auto", "left", "right", "above", "below".
          preview_split = "auto",
          -- This is the config that will be passed to nvim_open_win.
          -- Change values here to customize the layout
          override = function(conf)
            return conf
          end,
        },
      }

      -- Floating Oil
      vim.keymap.set("n", "<leader>of", function()
        require("oil").toggle_float()
      end, { desc = "Toggle Oil float" })

      -- Toggle hidden files (works inside Oil buffer)
      vim.keymap.set("n", "<leader>uh", function()
        require("oil.actions").toggle_hidden.callback()
      end, { desc = "Toggle hidden files in Oil" })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install",
      },
    },
    config = function()
      local telescope = require "telescope"
      local builtin = require "telescope.builtin"
      local actions = require "telescope.actions"

      telescope.setup {
        defaults = {
          mappings = {
            -- i = {
            --   ["<Esc>"] = actions.close,
            -- },
            n = {
              ["q"] = actions.close,
            },
          },
        },
      }

      -- Core Pickers
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
      vim.keymap.set("n", "<leader>fh", function()
        builtin.find_files {
          hidden = true,
          no_ignore = true,
        }
      end, { desc = "Find files (hidden + ignored)" })

      -- LSP Pickers
      vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "LSP references" })
      vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "LSP definitions" })
      vim.keymap.set("n", "gi", builtin.lsp_implementations, { desc = "LSP implementations" })
      vim.keymap.set("n", "<leader>ds", function()
        builtin.diagnostics {
          layout_strategy = "vertical",
          layout_config = {
            width = 0.95,
            height = 0.9,
            preview_height = 0.5,
            preview_cutoff = 0,
          },
          wrap_results = true,
          sorting_strategy = "ascending",
        }
      end, { desc = "Diagnostics picker" })
    end,
  },
}
