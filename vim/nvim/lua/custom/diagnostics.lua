-- diagnostics.lua - open diagnostics messages for current file in a temp buffer
-- For reading those really, really long diagnostics messages that don't fit in telescope

local M = {}
local buf = nil

local severity_labels = {
  [vim.diagnostic.severity.ERROR] = "ERROR",
  [vim.diagnostic.severity.WARN] = "WARN ",
  [vim.diagnostic.severity.INFO] = "INFO ",
  [vim.diagnostic.severity.HINT] = "HINT ",
}

local function format_diagnostics()
  local diagnostics = vim.diagnostic.get(0) -- 0 = current buffer
  if #diagnostics == 0 then
    return { "No diagnostics." }
  end

  -- sort by line number
  table.sort(diagnostics, function(a, b)
    return a.lnum < b.lnum
  end)

  local lines = {}
  for _, d in ipairs(diagnostics) do
    local sev = severity_labels[d.severity] or "?    "
    local source = d.source and ("[" .. d.source .. "] ") or ""
    table.insert(lines, string.format("%s  line %d:%d  %s%s", sev, d.lnum + 1, d.col, source, d.message))
  end
  return lines
end

local function create_buf()
  buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].swapfile = false
end

function M.open()
  create_buf()

  local lines = format_diagnostics()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.7)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(0, false)
  end, { buffer = buf, desc = "Close diagnostics buffer" })
end

return M
