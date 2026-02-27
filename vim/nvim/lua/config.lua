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
vim.cmd('autocmd BufEnter * set formatoptions-=cro')
vim.cmd('autocmd BufEnter * setlocal formatoptions-=cro')

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
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  require("plugins.theme"),
  require("plugins.navigation"),
  require("plugins.buffers"),
  require("plugins.comment"),
  require("plugins.session"),
  require("plugins.code"),
  require("plugins.terminal"),
})
