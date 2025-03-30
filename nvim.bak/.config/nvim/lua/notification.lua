-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Create an augroup to hold the custom autocommands
local augroup = vim.api.nvim_create_augroup("CustomMessages", { clear = true })

-- Custom message for saving a file
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = "*",
  -- callback = function() vim.api.nvim_echo({ { "[✔] Saved ", "Normal" } }, false, {}) end,
  callback = function() vim.api.nvim_echo({ { "    ", "Normal" } }, false, {}) end,
})

-- Autocommand for yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  pattern = "*",
  callback = function()
    -- Check if the operator is yank (y) and not delete (d)
    if vim.v.event.operator == "y" then
      -- Highlight the yanked text
      vim.highlight.on_yank { higroup = "IncSearch", timeout = 200 }

      -- Print a message indicating text was copied
      -- vim.api.nvim_echo({ { "[✔] Copied ", "Normal" } }, false, {})
      vim.api.nvim_echo({ { "    ", "Normal" } }, false, {})
    end
  end,
})

-- Function to check the undo state
local function check_undo_state()
  local undotree = vim.fn.undotree()
  if undotree.seq_cur == 0 then
    vim.api.nvim_echo({ { "[-] Oldest ", "Normal" } }, false, {})
  elseif undotree.seq_cur == undotree.seq_last then
    vim.api.nvim_echo({ { "[-] Newest ", "Normal" } }, false, {})
  end
end

-- Function to set up keymaps with custom messages
local function map_with_message(mode, lhs, rhs, message, check_undo)
  vim.keymap.set(mode, lhs, function()
    vim.cmd(rhs)
    vim.api.nvim_echo({ { message, "Normal" } }, false, {})
    if check_undo then check_undo_state() end
  end, { noremap = true, silent = true })
end

-- Set up keymaps for undo and redo
map_with_message("n", "u", "undo", "[↩] Undo ", true)
map_with_message("n", "<C-r>", "redo", "[↪] Redo ", true)

-- Set up keymaps for paste without undo state check
-- map_with_message("n", "p", "normal! p", "[✔] Pasted ", false)
-- map_with_message("n", "P", "normal! P", "[✔] Pasted ", false)
-- map_with_message("v", "p", "normal! p", "[✔] Pasted ", false)
-- map_with_message("v", "P", "normal! P", "[✔] Pasted ", false)
map_with_message("n", "p", "normal! p", "  󰢨  ", false)
map_with_message("n", "P", "normal! P", "  󰢨  ", false)
map_with_message("v", "p", "normal! p", "  󰢨  ", false)
map_with_message("v", "P", "normal! P", "  󰢨  ", false)
