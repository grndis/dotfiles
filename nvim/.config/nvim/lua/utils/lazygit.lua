local M = {}

function M.open_lazygit()
  print "open_lazygit function called"
  local function is_tmux() return vim.env.TMUX ~= nil end

  if is_tmux() then
    print "Opening in tmux"
    vim.cmd(string.format(":silent !tmux new-window -c %s -- lazygit", vim.fn.shellescape(vim.fn.getcwd())))
  else
    print "Opening in Neovim terminal"
    vim.cmd ":terminal lazygit"
    vim.cmd "startinsert"
  end
end

return M
