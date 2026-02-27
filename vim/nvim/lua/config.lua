-- config.lua
local o = vim.o
local opt = vim.opt
local g = vim.g

o.laststatus = 3
o.showmode = false
o.splitkeep = "screen"
o.splitbelow = true
o.splitright = true
o.signcolumn = "yes"
o.cursorline = true
o.cursorlineopt = "number"
o.clipboard = "unnamedplus"
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.number = true

o.mouse = "a"
o.undofile = true
opt.whichwrap:append "<>[]hl"
o.updatetime = 250
opt.hidden = true

g.mapleader = " "

-- Disable that annoying auto comment on new line
vim.cmd "autocmd BufEnter * set formatoptions-=cro"
vim.cmd "autocmd BufEnter * setlocal formatoptions-=cro"

-- Session management integrated with bufferline / scope
opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "skiprtp",
  "folds",
}

-- Disable default providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_python3_provider = 0

-- Lazy vim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  require "plugins.theme",
  require "plugins.navigation",
  require "plugins.buffers",
  require "plugins.comment",
  require "plugins.session",
  require "plugins.code",
  require "plugins.terminal",
  require "plugins.kanban",
}

-- Set up Kanban controls - creates .kanban.md in root when used
local kanban_state = {
  winid = nil,
}

local function open_project_kanban()
  local cwd = vim.fn.getcwd()
  local filename = ".kanban.md"
  local filepath = cwd .. "/" .. filename

  -- Create if missing
  if vim.fn.filereadable(filepath) == 0 then
    vim.cmd("KanbanCreate .kanban")
  end

  -- Always open explicitly
  vim.cmd("KanbanOpen " .. filename)

  -- Store window id (current window after open)
  kanban_state.winid = vim.api.nvim_get_current_win()
end

local function close_project_kanban()
  if kanban_state.winid and vim.api.nvim_win_is_valid(kanban_state.winid) then
    -- Focus the kanban window
    vim.api.nvim_set_current_win(kanban_state.winid)
    vim.cmd("KanbanClose")
    kanban_state.winid = nil
  end
end

local function toggle_project_kanban()
  if kanban_state.winid and vim.api.nvim_win_is_valid(kanban_state.winid) then
    close_project_kanban()
  else
    open_project_kanban()
  end
end

vim.keymap.set("n", "<leader>kb", toggle_project_kanban, { desc = "Toggle Project Kanban" })
