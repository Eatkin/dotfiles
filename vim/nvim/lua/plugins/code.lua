return {

  -- MASON
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = {
          -- Python: ty replaces pyright
          "cssls",
          "html",
          "emmet_ls",
          "lua_ls",
          "bashls",
          "yamlls",
          "asm_lsp",
          "jinja_lsp",
          "svelte",
          "ts_ls",
        },
        automatic_installation = true,
      }
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp_lsp = require "cmp_nvim_lsp"
      local capabilities = cmp_lsp.default_capabilities()

      -- Standard servers — no special config needed
      local simple_servers = {
        "html",
        "cssls",
        "emmet_ls",
        "bashls",
        "yamlls",
        "ts_ls",
        "asm_lsp",
        "jinja_lsp",
        "svelte",
      }
      for _, server in ipairs(simple_servers) do
        vim.lsp.config(server, { capabilities = capabilities })
      end

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      -- ty: replaces pyright, reads pyproject.toml automatically
      vim.lsp.config("ty", {
        capabilities = capabilities,
      })

      vim.lsp.enable {
        "ty",
        "lua_ls",
        "html",
        "cssls",
        "emmet_ls",
        "bashls",
        "yamlls",
        "ts_ls",
        "asm_lsp",
        "jinja_lsp",
        "svelte",
      }
    end,
  },

  -- TREESITTER
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").install {
        "lua",
        "python",
        "javascript",
        "typescript",
        "html",
        "css",
        "bash",
        "svelte",
      }
    end,
  },

  -- FORMATTER
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup {
        formatters_by_ft = {
          -- ruff_fix runs `ruff check --fix` (replaces isort pass)
          -- ruff_format runs `ruff format` (replaces black)
          python = { "ruff_fix", "ruff_format" },
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          svelte = { "prettier" },
          typescriptreact = { "prettier" },
          html = { "prettier", "djlint" },
          css = { "prettier" },
          scss = { "prettier" },
          sh = { "shfmt" },
          toml = { "pyproject-fmt" },
          asm = { "asmfmt" },
        },
      }
      vim.keymap.set("n", "<leader>fm", function()
        require("conform").format { async = true }
      end, { desc = "Format file" })
    end,
  },

  -- LINT
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require "lint"

      lint.linters_by_ft = {
        -- ruff only — ty diagnostics come through LSP, mypy lives in pre-commit
        python = { "ruff" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        svelte = { "eslint_d" },
        html = { "djlint" },
      }

      vim.keymap.set("n", "<leader>l", function()
        lint.try_lint()
      end, { desc = "Lint file" })

      vim.diagnostic.config {
        float = true,
        jump = { float = false, wrap = true },
        severity_sort = false,
        signs = true,
        underline = true,
        update_in_insert = false,
        virtual_lines = false,
        virtual_text = true,
      }
    end,
  },

  -- AUTOCOMPLETE
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require "cmp"
      local luasnip = require "luasnip"

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      }
    end,
  },

  vim.filetype.add {
    extension = { asm = "nasm" },
  },
}
