return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- optional, but recommended
  },
  lazy = false, -- neo-tree will lazily load itself
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
    popup_border_style = "NC", -- or "" to use 'winborder' on Neovim v0.11+
    -- clipboard = {
    --   sync = "none", -- or "global"/"universal" to share a clipboard for each/all Neovim instance(s), respectively
    -- },
    enable_git_status = true,
    enable_diagnostics = false,
    -- open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
    -- open_files_using_relative_paths = false,
    -- sort_case_insensitive = false, -- used when sorting files and directories in the tree
    -- sort_function = nil, -- use a custom function for sorting files and directories in the tree
    -- sort_function = function (a,b)
    --       if a.type == b.type then
    --           return a.path > b.path
    --       else
    --           return a.type > b.type
    --       end
    --   end , -- this sorts files and directories descendantly
    -- default_component_configs = {
    --   container = {
    --     enable_character_fade = true,
    --   },
    --   indent = {},
    --   icon = {},
    --   modified = {},
    --   name = {},
    --   git_status = {
    --     symbols = {},
    --   },
    --   -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
    --   file_size = {
    --     enabled = true,
    --     width = 12, -- width of the column
    --     required_width = 64, -- min width of window required to show this column
    --   },
    --   type = {
    --     enabled = true,
    --     width = 10, -- width of the column
    --     required_width = 122, -- min width of window required to show this column
    --   },
    --   last_modified = {
    --     enabled = true,
    --     width = 20, -- width of the column
    --     required_width = 88, -- min width of window required to show this column
    --   },
    --   created = {
    --     enabled = true,
    --     width = 20, -- width of the column
    --     required_width = 110, -- min width of window required to show this column
    --   },
    --   symlink_target = {
    --     enabled = false,
    --   },
    -- },
    -- A list of functions, each representing a global custom command
    -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
    -- see `:h neo-tree-custom-commands-global`
    -- commands = {},
    window = {
      position = "left",
      width = 28,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {},
    },
    -- nesting_rules = {},
    -- filesystem = {
    --   filtered_items = {
    --     visible = true, -- when true, they will just be displayed differently than normal items
    --     hide_dotfiles = false,
    --     hide_gitignored = false,
    --     hide_ignored = false, -- hide files that are ignored by other gitignore-like files
    --     -- other gitignore-like files, in descending order of precedence.
    --     ignore_files = {
    --       ".neotreeignore",
    --       ".ignore",
    --       -- ".rgignore"
    --     },
    --     hide_hidden = false, -- only works on Windows for hidden files/directories
    --     hide_by_name = {
    --       --"node_modules"
    --     },
    --     hide_by_pattern = { -- uses glob style patterns
    --       --"*.meta",
    --       --"*/src/*/tsconfig.json",
    --     },
    --     always_show = { -- remains visible even if other settings would normally hide it
    --       --".gitignored",
    --     },
    --     always_show_by_pattern = { -- uses glob style patterns
    --       --".env*",
    --     },
    --     never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
    --       ".DS_Store",
    --       --"thumbs.db"
    --     },
    --     never_show_by_pattern = { -- uses glob style patterns
    --       --".null-ls_*",
    --     },
    --   },
    --   follow_current_file = {
    --     enabled = true, -- This will find and focus the file in the active buffer every time
    --     --               -- the current file is changed while the tree is open.
    --     leave_dirs_open = true, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
    --   },
    --   group_empty_dirs = false, -- when true, empty folders will be grouped together
    --   -- hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
    --   -- in whatever position is specified in window.position
    --   -- "open_current",  -- netrw disabled, opening a directory opens within the
    --   -- window like netrw would, regardless of window.position
    --   -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    --   use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
    --   -- instead of relying on nvim autocmd events.
    --   window = {
    --     mappings = {},
    --     fuzzy_finder_mappings = {},
    --   },
    --
    --   commands = {}, -- Add a custom command or override a global one using the same function name
    -- },
    -- buffers = {
    --   follow_current_file = {
    --     -- enabled = false, -- This will find and focus the file in the active buffer every time
    --     --              -- the current file is changed while the tree is open.
    --     leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
    --   },
    --   group_empty_dirs = true, -- when true, empty folders will be grouped together
    --   -- show_unloaded = true,
    --   window = {},
    -- },
    -- git_status = {
    --   window = {
    --     -- position = "float",
    --     mappings = {},
    --   },
    -- },
    -- options go here
  },
}
