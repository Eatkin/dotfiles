return {
  {
    "milanglacier/minuet-ai.nvim",
    opts = {
      provider = "openai_fim_compatible",
      n_completions = 1,
      context_window = 2048,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM",
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:3b",
          stream = true,
          transform = {
            function(request)
              if request and request.body then
                request.body.insert = nil
              end
              return request
            end,
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = {
          "python",
          "css",
          "html",
          "lua",
          "bash",
          "asm",
          "jinja2",
          "svelte",
          "javascript",
          "typescript",
          "sh",
        },
        keymap = {
          accept = "<C-a>", -- Basically tab hijacks so use ctrl+A instead
          accept_line = "<C-y>",
          next = "<A-]>",
          prev = "<A-[>",
          dismiss = "<C-e>",
        },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "stevearc/dressing.nvim", opts = {} },
    },
    config = function()
      require("codecompanion").setup {
        adapters = {
          http = {
            qwen = function()
              return require("codecompanion.adapters").extend("ollama", {
                name = "qwen",
                schema = {
                  model = { default = "qwen2.5-coder:7b" },
                  num_ctx = { default = 8192 },
                },
              })
            end,
            gemma4_e2b = function()
              return require("codecompanion.adapters").extend("ollama", {
                name = "gemma4_e2b",
                schema = {
                  model = { default = "gemma4:e2b" },
                  num_ctx = { default = 8192 },
                },
              })
            end,
          },
        },
        interactions = {
          chat = { adapter = "qwen" },
          inline = { adapter = "qwen" },
        },
        display = {
          chat = {
            window = {
              layout = "vertical",
              width = 0.35,
            },
          },
        },
      }

      local map = vim.keymap.set
      map({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI chat" })
      map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI actions" })
      map("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { desc = "add to chat" })
    end,
  },
}
