-- scratch.lua - persistent scratch buffer for when I need to write random notes

local M = {}
local buf = nil

-- Path named after project
local function scratch_path()
  return vim.fn.getcwd() .. '/.scratch.md'
end

local function create_buf()
  buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].swapfile = false

   -- load existing notes if present
  local path = scratch_path()
  if vim.fn.filereadable(path) == 1 then
    local lines = vim.fn.readfile(path)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  -- save on hide
  vim.api.nvim_create_autocmd('BufHidden', {
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      vim.fn.writefile(lines, scratch_path())
    end,
  })
end

local function open_float()
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    create_buf()
  end

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.7)

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
  })

   -- q to close in normal mode
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(0, false)
  end, { buffer = buf, desc = 'Close scratch buffer' })
end

function M.toggle()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      vim.api.nvim_win_close(win, false)
      return
    end
  end
  open_float()
end

return M
