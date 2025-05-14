-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
return {
  "kdheepak/lazygit.nvim",
  lazy = true,
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
  config = function()
    vim.keymap.set("t", "<C-c>", function()
      vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
      vim.api.nvim_command "LLMAppHandler CommitMsg"
    end, { desc = "AI Commit Msg" })
  end,
}

-- -- nvim v0.8.0
-- return {
--   "kdheepak/lazygit.nvim",
--   cmd = {
--     "LazyGit",
--     "LazyGitConfig",
--     "LazyGitCurrentFile",
--     "LazyGitFilter",
--     "LazyGitFilterCurrentFile",
--   },
--   -- optional for floating window border decoration
--   dependencies = {
--     "nvim-lua/plenary.nvim",
--   },
--   -- setting the keybinding for LazyGit with 'keys' is recommended in
--   -- order to load the plugin when the command is run for the first time
--   keys = {
--     { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
--   },
-- }
