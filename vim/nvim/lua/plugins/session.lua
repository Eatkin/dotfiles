return {
	{
		"jedrzejboczar/possession.nvim",
		lazy = false,
		dependencies = {
			{ "tiagovla/scope.nvim", lazy = false, config = true },
			{ "nvim-lua/plenary.nvim" },
		},
		config = function()
			require("possession").setup({
				autoload = false,
				plugins = {
					delete_hidden_buffers = false,
				},
				hooks = {
          -- This sets syntax highlighting after buffer reopens
					after_load = function()
						vim.schedule(function()
							-- Ensure filetypes are correct
							vim.cmd("silent! filetype detect")

							-- Re-enable treesitter safely
							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_is_loaded(buf) then
									local bt = vim.bo[buf].buftype
									if bt == "" then
										pcall(vim.treesitter.start, buf)
									end
								end
							end
						end)
					end,
				},
			})

			-- Load session after other stuff
			vim.api.nvim_create_autocmd("VimEnter", {
				once = true,
				callback = function()
					vim.schedule(function()
						vim.cmd("PossessionLoadCwd")
					end)
				end,
			})

			-- Nuclear quit: save session (by cwd) then quit all
			vim.api.nvim_create_user_command("NukeQuit", function()
				vim.cmd("wall")
				vim.cmd("PossessionSaveCwd!")
				vim.cmd("qa")
			end, { desc = "Write all, save session and quit all of Neovim" })

			-- Keybind <leader>qq
			vim.keymap.set("n", "<leader>qq", function()
				vim.cmd("NukeQuit")
			end, { desc = "Save session and quit all" })
		end,
	},
}
