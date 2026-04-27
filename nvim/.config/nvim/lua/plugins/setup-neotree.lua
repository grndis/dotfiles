return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    "3rd/image.nvim",
  },
  opts = {
    enable_diagnostics = false,
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

    local function refresh_neotree()
      local events = require "neo-tree.events"
      events.fire_event(events.GIT_EVENT)
    end

    -- Only refresh git status when neo-tree is actually visible
    vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
      callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
            refresh_neotree()
            return
          end
        end
      end,
      desc = "Refresh NeoTree when files change (only if visible)",
    })
  end,
}