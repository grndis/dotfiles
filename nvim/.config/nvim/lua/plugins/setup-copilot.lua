if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "User AstroFile",
    opts = { suggestion = { enabled = false }, panel = { enabled = false } },
  },
  {
    "giuxtaposition/blink-cmp-copilot",
  },
}
