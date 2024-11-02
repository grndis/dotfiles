local M = {}

local fterm = require "FTerm"

M.atac = fterm:new {
  ft = "fterm_atac",
  cmd = "ATAC_THEME=$HOME/.config/atac/themes/theme.toml "
    .. "ATAC_KEY_BINDINGS=$HOME/.config/atac/key_bindings/vim.toml "
    .. "atac",
  dimensions = {
    height = 0.9,
    width = 0.9,
  },
}

return M
