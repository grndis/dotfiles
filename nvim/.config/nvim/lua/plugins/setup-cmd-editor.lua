if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  "smilhey/ed-cmd.nvim",
  config = function()
    require("ed-cmd").setup {
      -- Those are the default options, you can just call setup({}) if you don't want to change the defaults
      cmdline = { keymaps = { edit = "<ESC>", execute = "<CR>" } },
      -- You enter normal mode in the cmdline with edit and execute a command from normal mode with execute
      pumenu = { max_items = 100 },
    }
  end,
}
