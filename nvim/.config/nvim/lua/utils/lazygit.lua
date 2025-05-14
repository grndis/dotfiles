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
--
-- local M = {}
--
-- -- Initialize FTerm lazygit instance
-- local fterm = require "FTerm"
-- local lazygit_term = fterm:new {
--   ft = "fterm_lazygit",
--   cmd = "lazygit",
--   dimensions = {
--     height = 0.9,
--     width = 0.9,
--   },
-- }
--
-- function M.open_lazygit()
--   local function is_tmux() return vim.env.TMUX ~= nil end
--
--   if is_tmux() then
--     -- Use tmux popup if in tmux
--     vim.fn.system 'tmux popup -d "#{pane_current_path}" -xC -yC -w90% -h90% -E "lazygit  --use-config-file=$HOME/.config/lazygit/theme.yml"'
--   else
--     -- Use FTerm if not in tmux
--     lazygit_term:toggle()
--   end
-- end
--
-- return M
--
--

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
  on_open = function()
    -- Set up the <C-c> keymap when the terminal opens
    vim.keymap.set("t", "<C-c>", function()
      vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
      vim.api.nvim_command "LLMAppHandler CommitMsg"
    end, { desc = "AI Commit Msg", buffer = 0 }) -- buffer = 0 means current buffer
  end,
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

-- Initialize the module
function M.setup()
  -- If you're using tmux, you might need a different approach for the keymap
  -- since the terminal is managed by tmux in that case
  if vim.env.TMUX ~= nil then
    -- You might need to handle tmux-specific keybindings differently
    -- This is more complex and might require tmux configuration
  end
end

return M
