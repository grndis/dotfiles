return {
  -- ~/.config/nvim/lua/setup-noice.lua

  require("noice").setup {
    presets = {
      bottom_search = false, -- use a classic bottom cmdline for search
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        view = "notify",
        opts = {
          title = "Saved",
        },
      },
    },
  },
}
