-- vim.api.nvim_set_keymap("n", "<C-k>", ":lua require('kulala').jump_prev()<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<C-j>", ":lua require('kulala').jump_next()<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<C-l>", ":lua require('kulala').run()<CR>", { noremap = true, silent = true })
--
vim.keymap.set("n", "<leader>gg", function() require("utils.lazygit").open_lazygit() end, {
  desc = "LazyGit",
})

vim.keymap.set("n", "<leader>ta", function() require("utils.atac").open_atac() end, {
  desc = "Atac",
})

vim.api.nvim_set_keymap(
  "n",
  "<leader>as",
  "<cmd>CodeCompanionActions<cr>",
  { noremap = true, silent = true, desc = "AI Actions" }
)
vim.api.nvim_set_keymap(
  "v",
  "<leader>as",
  "<cmd>CodeCompanionActions<cr>",
  { noremap = true, silent = true, desc = "AI Actions" }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>aa",
  "<cmd>CodeCompanionChat Toggle<cr>",
  { noremap = true, silent = true, desc = "AI Chat" }
)
vim.api.nvim_set_keymap(
  "v",
  "<leader>aa",
  "<cmd>CodeCompanionChat Toggle<cr>",
  { noremap = true, silent = true, desc = "AI Chat" }
)
vim.api.nvim_set_keymap(
  "v",
  "<leader>ad",
  "<cmd>CodeCompanionChat Add<cr>",
  { noremap = true, silent = true, desc = "AI Add" }
)

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd [[cab cc CodeCompanion]]

local wk = require "which-key"
wk.add {
  { "<leader>a", group = "󰚩 AI" },
}
