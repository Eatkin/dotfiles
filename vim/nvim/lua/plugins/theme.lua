return {
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		config = function()
			vim.cmd("colorscheme nightfox")
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key")

		end,
	},
}
