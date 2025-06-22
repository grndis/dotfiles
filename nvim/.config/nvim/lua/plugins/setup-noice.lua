-- if true then return {} end -- Disable noice

return {
  -- ~/.config/nvim/lua/setup-noice.lua

  require("noice").setup {
    format = {
      substitute = {
        pattern = "^:%%?s/",
        icon = " ",
        ft = "regex",
        opts = { border = { text = { top = " sub (old/new/) " } } },
      },
    },
    messages = {
      enabled = true, -- enables the Noice messages UI
      view = "mini", -- default view for messages
      view_error = "mini", -- view for errors
      view_warn = "mini", -- view for warnings
      view_history = "messages", -- view for :messages
      view_search = "mini", -- view for search count messages. Set to `false` to disable
    },
    presets = {
      bottom_search = false, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = true, -- enables an input dialog for inc-rename.nvim
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
          find = "before #", -- This will match any message containing "before #"
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
          find = "after #", -- This will match any message containing "after #"
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
      ---------------------- Disable Notification --------------------------------
      {
        filter = {
          any = {
            { event = "msg_show", kind = "" },
            { event = "notify", kind = "" },
            { event = "msg_show", kind = "echomsg" },
            { event = "notify", kind = "info" },
            -- { event = "notify", find = "Minuet" },
            -- { event = "msg_show", kind = "emsg", find = "E%d+:" },
            -- { event = "msg_show", kind = "", find = "E382:" },
            { error = true },
            { warning = true },
            { event = "lsp" },
            -- { event = "none-ls" },
          },
        },
        opts = {
          skip = true,
        },
      },
    },
  },
}
