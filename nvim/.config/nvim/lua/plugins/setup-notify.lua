if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  "rcarriga/nvim-notify",
  opts = {
    stages = "slide", -- fade_in_slide_out
    max_width = 30,
    max_height = 1,
    timeout = 100,
    fps = 60,
  },
}
