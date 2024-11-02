local M = {}

local fterm = require "FTerm"

M.lazygit = fterm:new {
  ft = "fterm_lazygit",
  cmd = "lazygit",
  dimensions = {
    height = 0.9,
    width = 0.9,
  },
}

return M
