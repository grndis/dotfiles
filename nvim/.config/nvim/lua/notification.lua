-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Custom message for saving a file
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("CustomMessages", { clear = true }),
  pattern = "*",
  callback = function() vim.api.nvim_echo({ { "File saved!", "Normal" } }, false, {}) end,
})

--
-- -- Custom message for yank
-- autocmd("TextYankPost", {
--   group = "CustomMessages",
--   pattern = "*",
--   callback = function() print "Copied!" end,
-- })
--
-- -- Function to check undo tree state
-- local function check_undo_state()
--   local undotree = vim.fn.undotree()
--   if undotree.seq_cur == 0 then
--     print "Reached oldest change!"
--   elseif undotree.seq_cur == undotree.seq_last then
--     print "Reached newest change!"
--   end
-- end
--
-- -- Function to set up keymaps with custom messages
-- local function map_with_message(mode, lhs, rhs, message, check_undo)
--   vim.keymap.set(mode, lhs, function()
--     vim.cmd(rhs)
--     print(message)
--     if check_undo then check_undo_state() end
--   end, { noremap = true, silent = true })
-- end
--
-- -- Set up keymaps for undo and redo
-- map_with_message("n", "u", "undo", "Undo performed!", true)
-- map_with_message("n", "<C-r>", "redo", "Redo performed!", true)
--
-- -- Set up keymaps for paste without undo state check
-- map_with_message("n", "p", "normal! p", "Pasted!", false)
-- map_with_message("n", "P", "normal! P", "Pasted!", false)
-- map_with_message("v", "p", "normal! p", "Pasted!", false)
-- map_with_message("v", "P", "normal! P", "Pasted!", false)
