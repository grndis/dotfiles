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
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "E382:",
        },
        opts = {
          skip = true,
        },
      },
      {
        filter = {
          event = "msg_show",
          kind = "emsg",
          find = "E%d+:",
        },
        opts = {
          skip = true,
        },
      },
      {
        filter = {
          event = "notify",
          find = "Reloading",
        },
        opts = {
          skip = true,
        },
      },
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "before #", -- This will match any message containing "before #"
        },
        view = "notify",
        opts = {
          title = "Undo",
        },
      },
      -- Route for redo
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "after #", -- This will match any message containing "after #"
        },
        view = "notify",
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
        view = "notify",
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
        view = "notify",
        opts = {
          title = "Newest",
        },
      },
      {
        filter = {
          event = "msg_show",
          kind = "",
        },
        opts = {
          skip = true,
        },
      },
    },
  },
}
