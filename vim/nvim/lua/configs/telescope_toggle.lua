local M = {}

local ok, telescope = pcall(require, "telescope.builtin")
if not ok then return M end

local my_find_files
my_find_files = function(opts, no_ignore)
    opts = opts or {}
    no_ignore = no_ignore == nil and false or no_ignore

    opts.attach_mappings = function(_, map)
        map({ "n", "i" }, "<C-h>", function(prompt_bufnr)
            local prompt = require("telescope.actions.state").get_current_line()
            require("telescope.actions").close(prompt_bufnr)
            no_ignore = not no_ignore
            my_find_files({ default_text = prompt }, no_ignore)
        end)
        return true
    end

    if no_ignore then
        opts.no_ignore = true
        opts.hidden = true
        opts.prompt_title = "Find Files <ALL>"
        telescope.find_files(opts)
    else
        opts.prompt_title = "Find Files"
        telescope.find_files(opts)
    end
end

vim.keymap.set("n", "<leader>fg", my_find_files, { noremap = true, silent = true })

return M
