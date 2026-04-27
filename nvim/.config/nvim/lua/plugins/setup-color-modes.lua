-- if true then return {} end

---@type LazySpec
return {
  "mvllow/modes.nvim",
  opts = {
    colors = {
      bg = "",
      copy = "#f5c359",
      delete = "#c75c6a",
      insert = "#78ccc5",
      visual = "#D0B5FA",
    },
    line_opacity = 0.15,
    set_cursor = true,
    set_cursorline = true,
    set_number = true,
    ignore_filetypes = { "NvimTree", "TelescopePrompt" },
  },
}