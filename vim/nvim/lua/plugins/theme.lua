return {
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    config = function()
      vim.cmd "colorscheme nightfox"
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require "which-key"
    end,
  },

  {
    "dimtion/guttermarks.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre", "FileType" },

    config = function()
      -- Local marks
      local letters = "abcdefghijklmnopqrstuvwxyz"

      for i = 1, #letters do
        local mark = letters:sub(i, i)

        -- Set mark
        vim.keymap.set("n", "<leader>ms" .. mark, function()
          vim.cmd("mark " .. mark)
          vim.cmd "GutterMarks refresh"
        end, { desc = "Mark: set " .. mark })

        -- Delete mark
        vim.keymap.set("n", "<leader>md" .. mark, function()
          vim.cmd("delmarks " .. mark)
          vim.cmd "GutterMarks refresh"
        end, { desc = "Mark: delete " .. mark })

        -- Jump to mark
        vim.keymap.set("n", "<leader>mj" .. mark, function()
          vim.cmd("normal! '" .. mark)
          vim.cmd "GutterMarks refresh"
        end, { desc = "Mark: jump " .. mark })
      end

      -- Delete all local marks
      vim.keymap.set("n", "<leader>md!", function()
        vim.cmd "delmarks a-z"
        vim.cmd "GutterMarks refresh"
      end, { desc = "Mark: delete all local" })

      local globals = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

      -- Global marks
      for i = 1, #globals do
        local mark = globals:sub(i, i)

        vim.keymap.set("n", "<leader>ms" .. mark, function()
          vim.cmd("mark " .. mark)
          vim.cmd "GutterMarks refresh"
        end, { desc = "Mark: set global " .. mark })

        vim.keymap.set("n", "<leader>md" .. mark, function()
          vim.cmd("delmarks " .. mark)
          vim.cmd "GutterMarks refresh"
        end, { desc = "Mark: delete global " .. mark })

        vim.keymap.set("n", "<leader>mj" .. mark, function()
          vim.cmd("normal! '" .. mark)
          vim.cmd "GutterMarks refresh"
        end, { desc = "Mark: jump global " .. mark })
      end

      -- Delete all global marks
      vim.keymap.set("n", "<leader>mgd!", function()
        vim.cmd "delmarks A-Z"
        vim.cmd "GutterMarks refresh"
      end, { desc = "Mark: delete all global" })

      -- Telescope marks picker
      vim.keymap.set("n", "<leader>ml", function()
        require("telescope.builtin").marks {}
      end, { desc = "Marks: local a-z" })
    end,
  },
}
