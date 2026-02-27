return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",

		config = function()
			require("toggleterm").setup({
				open_mapping = nil,
				start_in_insert = true,
				shade_terminals = false,

				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return 60
					end
				end,
			})

			local Terminal = require("toggleterm.terminal").Terminal

			-- Horizontal
			local term_h = Terminal:new({ direction = "horizontal" })
			vim.keymap.set({ "n", "i", "t" }, "<A-h>", function()
				term_h:toggle()
			end, { desc = "Horizontal Terminal" })

			-- Vertical
			local term_v = Terminal:new({ direction = "vertical" })
			vim.keymap.set({ "n", "i", "t" }, "<A-l>", function()
				term_v:toggle()
			end, { desc = "Vertical Terminal" })

			-- Float
			local term_f = Terminal:new({ direction = "float" })
			vim.keymap.set({ "n", "i", "t" }, "<A-f>", function()
				term_f:toggle()
			end, { desc = "Floating Terminal" })
		end,
	},
}
