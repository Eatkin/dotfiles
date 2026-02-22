---@type ChadrcConfig
local M = {}

-- Base46: only UI / theme stuff
M.base46 = {
    theme = "onedark",
}

pcall(require, "configs.telescope_toggle")

return M
