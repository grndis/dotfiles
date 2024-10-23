local M = {}

function M.open_lazygit()
  local function is_tmux() return vim.env.TMUX ~= nil end

  if is_tmux() then
    vim.cmd(string.format(":silent !tmux new-window -c %s -- lazygit", vim.fn.shellescape(vim.fn.getcwd())))
  else
    -- Save the current buffer number
    local current_buf = vim.api.nvim_get_current_buf()

    -- Open lazygit in a new buffer
    vim.cmd "enew"
    local lazygit_buf = vim.api.nvim_get_current_buf()

    local chan = vim.fn.termopen("lazygit", {
      on_exit = function()
        -- Close the lazygit buffer and return to the previous buffer
        vim.schedule(function()
          -- Check if the original buffer still exists
          if vim.api.nvim_buf_is_valid(current_buf) then vim.api.nvim_set_current_buf(current_buf) end
          vim.api.nvim_buf_delete(lazygit_buf, { force = true })
        end)
      end,
    })

    -- Enter insert mode
    vim.cmd "startinsert"
  end
end

return M
