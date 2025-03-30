-- local M = {}
--
-- local fterm = require "FTerm"
--
-- M.atac = fterm:new {
--   ft = "fterm_atac",
--   cmd = "ATAC_THEME=$HOME/.config/atac/themes/theme.toml "
--     .. "ATAC_KEY_BINDINGS=$HOME/.config/atac/key_bindings/vim.toml "
--     .. "atac",
--   dimensions = {
--     height = 0.9,
--     width = 0.9,
--   },
-- }
--
-- return M

local M = {}

-- Initialize FTerm lazygit instance
local fterm = require "FTerm"
local lazygit_term = fterm:new {
  ft = "fterm_atac",
  cmd = "ATAC_THEME=$HOME/.config/atac/themes/theme.toml "
    .. "ATAC_KEY_BINDINGS=$HOME/.config/atac/key_bindings/vim.toml "
    .. "atac",
  dimensions = {
    height = 0.9,
    width = 0.9,
  },
}

function M.open_atac()
  local function is_tmux() return vim.env.TMUX ~= nil end

  if is_tmux() then
    -- Use tmux popup if in tmux
    vim.fn.system 'tmux popup -d "#{pane_current_path}" -xC -yC -w90% -h90% -E "ATAC_THEME=$HOME/.config/atac/themes/theme.toml ATAC_KEY_BINDINGS=$HOME/.config/atac/key_bindings/vim.toml atac"'
  else
    -- Use FTerm if not in tmux
    lazygit_term:toggle()
  end
end

return M
