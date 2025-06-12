-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- local M = {}
--
-- local fterm = require "FTerm"
--
-- M.lazygit = fterm:new {
--   ft = "fterm_lazygit",
--   cmd = "lazygit",
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
  ft = "fterm_lazygit",
  cmd = "lazygit",
  dimensions = {
    height = 0.9,
    width = 0.9,
  },
}

function M.open_lazygit()
  local function is_tmux() return vim.env.TMUX ~= nil end

  if is_tmux() then
    -- Use tmux popup if in tmux
    vim.fn.system 'tmux popup -d "#{pane_current_path}" -xC -yC -w90% -h90% -E "lazygit  --use-config-file=$HOME/.config/lazygit/theme.yml"'
  else
    -- Use FTerm if not in tmux
    lazygit_term:toggle()
  end
end

return M
