if true then return {} end -- Disable notify

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
