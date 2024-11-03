-- vim.api.nvim_set_keymap("n", "<C-k>", ":lua require('kulala').jump_prev()<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<C-j>", ":lua require('kulala').jump_next()<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<C-l>", ":lua require('kulala').run()<CR>", { noremap = true, silent = true })
--
-- vim.keymap.set("n", "<leader>gg", function() require("utils.lazygit").open_lazygit() end, {
--   desc = "LazyGit",
-- })
vim.keymap.set("n", "<leader>gg", function() require("utils.lazygit").lazygit:toggle() end, {
  desc = "LazyGit",
})

vim.keymap.set("n", "<leader>ta", function() require("utils.atac").atac:toggle() end, {
  desc = "Open Atac",
})

vim.keymap.set("n", "<leader>r", ":checktime<CR>", { silent = true, desc = "Reload" })

vim.keymap.set(
  "n",
  "<leader>aa",
  "<cmd>CodeCompanionActions<cr>",
  { noremap = true, silent = true, desc = "AI Actions" }
)
vim.keymap.set(
  "v",
  "<leader>aa",
  "<cmd>CodeCompanionActions<cr>",
  { noremap = true, silent = true, desc = "AI Actions" }
)

vim.keymap.set(
  "n",
  "<leader>ai",
  "<cmd>CodeCompanionChat Toggle<cr>",
  { noremap = true, silent = true, desc = "AI Chat" }
)

vim.keymap.set(
  "v",
  "<leader>ai",
  "<cmd>CodeCompanionChat Toggle<cr>",
  { noremap = true, silent = true, desc = "AI Chat" }
)

vim.keymap.set("v", "<leader>ad", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true, desc = "AI Add" })

vim.keymap.set("n", "<leader>tt", '<CMD>lua require("FTerm").toggle()<CR>', { desc = "Open Terminal" })
vim.keymap.set("t", "<leader>tt", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd [[cab cc CodeCompanion]]

local wk = require "which-key"
wk.add {
  { "<leader>a", group = " AI" },
  { "<leader>t", group = " Terminal" },
}
