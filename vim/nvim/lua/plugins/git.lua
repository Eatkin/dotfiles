return {
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},

				current_line_blame = false,
			})

			local gs = package.loaded.gitsigns

			-- Navigate hunks
			vim.keymap.set("n", "]h", gs.next_hunk, { desc = "Next hunk" })
			vim.keymap.set("n", "[h", gs.prev_hunk, { desc = "Prev hunk" })

			-- Preview hunk
			vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })

			-- Stage / reset hunk
			vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
			vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })

			-- Blame line
			vim.keymap.set("n", "<leader>hb", gs.blame_line, { desc = "Blame line" })
		end,
	},
}
