-- if true then return {} end -- Disable noice

---@type LazySpec
return {
  "folke/noice.nvim",
  opts = {
    format = {
      substitute = {
        pattern = "^:%%?s/",
        icon = "",
        ft = "regex",
        opts = { border = { text = { top = " sub (old/new/) " } } },
      },
    },
    messages = {
      enabled = true,
      view = "mini",
      view_error = "mini",
      view_warn = "mini",
      view_history = "messages",
      view_search = "mini",
    },
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
    },
    notify = {
      enabled = false,
    },
    popupmenu = {
      enable = false,
    },
    cmdline = {
      format = {
        search_down = {
          view = "cmdline",
        },
        search_up = {
          view = "cmdline",
        },
      },
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
          find = "before #",
        },
        view = "mini",
        opts = {
          title = "Undo",
        },
      },
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "after #",
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
          find = "copied!",
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
          find = "Pasted",
        },
        view = "mini",
        opts = {
          title = "Pasted!",
        },
      },
      {
        filter = {
          any = {
            { event = "msg_show", kind = "" },
            { event = "notify", kind = "" },
            { event = "msg_show", kind = "echomsg" },
            { event = "notify", kind = "info" },
            { error = true },
            { warning = true },
            { event = "lsp" },
          },
        },
        opts = {
          skip = true,
        },
      },
    },
  },
}