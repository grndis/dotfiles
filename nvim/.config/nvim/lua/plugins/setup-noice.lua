-- if true then return {} end -- Disable noice

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
          find = "saved",
        },
        view = "mini",
        opts = {
          title = "Saved",
        },
      },
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "Undo", -- This will match any message containing "before #"
        },
        view = "mini",
        opts = {
          title = "Undo",
        },
      },
      -- Route for redo
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "Redo", -- This will match any message containing "after #"
        },
        view = "mini",
        opts = {
          title = "Redo",
        },
      },
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "oldest",
        },
        view = "mini",
        opts = {
          title = "Oldest",
        },
      },
      -- Route for "Already at newest change"
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "newest",
        },
        view = "mini",
        opts = {
          title = "Newest",
        },
      },
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "Copied!",
        },
        view = "mini",
        opts = {
          title = "Copied!",
        },
      },
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "Pasted!",
        },
        view = "mini",
        opts = {
          title = "Pasted!",
        },
      },
      ---------------------- Disable Notification --------------------------------
      {
        filter = {
          any = {
            { event = "msg_show", kind = "" },
            { event = "notify", find = "Reloading" },
            { event = "msg_show", kind = "emsg", find = "E%d+:" },
            { event = "msg_show", kind = "", find = "E382:" },
          },
        },
        opts = {
          skip = true,
        },
      },
    },
  },
}
