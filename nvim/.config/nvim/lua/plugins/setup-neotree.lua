return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    "3rd/image.nvim",
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          ".DS_Store",
        },
        never_show = {
          ".DS_Store",
        },
        never_show_by_pattern = {
          ".null-ls_*",
        },
      },
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)

    -- Function to auto-refresh NeoTree when files change
    local function refresh_neotree()
      local events = require "neo-tree.events"
      events.fire_event(events.GIT_EVENT)
    end

    -- Set up an autocmd to call the refresh function
    vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
      callback = function() refresh_neotree() end,
      desc = "Refresh NeoTree when files change",
    })
  end,
}
