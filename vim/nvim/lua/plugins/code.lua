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
			require("mason-lspconfig").setup({
				ensure_installed = {
					"pyright",
					"cssls",
					"html",
					"emmet_ls",
					"lua_ls",
				},
				automatic_installation = true,
			})
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig", -- still needed for server definitions
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local mason = require("mason")
			local mason_lsp = require("mason-lspconfig")
			local cmp_lsp = require("cmp_nvim_lsp")

			mason.setup()

			mason_lsp.setup({
				ensure_installed = {
					"pyright",
					"lua_ls",
					"html",
					"cssls",
					"emmet_ls",
				},
				automatic_installation = true,
			})

			local capabilities = cmp_lsp.default_capabilities()

			-- New 0.11 native API
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				settings = {
					python = {
						analysis = {
							diagnosticMode = "openFilesOnly",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})
			-- vim.lsp.config("lua_ls", { capabilities = capabilities })
			vim.lsp.config("html", { capabilities = capabilities })
			vim.lsp.config("cssls", { capabilities = capabilities })
			vim.lsp.config("emmet_ls", { capabilities = capabilities })

			-- Enable them
			vim.lsp.enable({
				"pyright",
				"lua_ls",
				"html",
				"cssls",
				"emmet_ls",
			})
		end,
	},

	-- TREESITTER
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local ts = require("nvim-treesitter")

			-- Install parsers
			ts.install({
				"lua",
				"python",
				"javascript",
				"html",
				"css",
				"bash",
			})
		end,
	},

	-- FORMATTER
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					python = { "isort", "black" },
					lua = { "stylua" },
					javascript = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					sh = { "shfmt" },
				},
			})

			vim.keymap.set("n", "<leader>fm", function()
				require("conform").format({ async = true })
			end, { desc = "Format file" })
		end,
	},

	-- LINT
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				python = { "ruff", "mypy" },
				javascript = { "eslint_d" },
			}

			vim.keymap.set("n", "<leader>l", function()
				lint.try_lint()
			end, { desc = "Lint file" })


			vim.diagnostic.config({
				float = true,
				jump = {
					float = false,
					wrap = true,
				},
				severity_sort = false,
				signs = true,
				underline = true,
				update_in_insert = false,

				virtual_lines = false,
				virtual_text = true,
			})
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
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),

				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},
}
