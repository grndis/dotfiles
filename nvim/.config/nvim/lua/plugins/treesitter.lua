-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "php",
      "php_only",
      "vue",
      "blade",
      "javascript",
      "json",
      "sql",
      "git_config",
      "html",
      "css",
      -- add more arguments for adding more treesitter parsers
    },
    highlight = {
      enable = true,
    },
  },
  config = function(_, opts)
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

    parser_config.blade = {
      install_info = {
        url = "https://github.com/EmranMR/tree-sitter-blade",
        files = { "src/parser.c" },
        branch = "main",
      },
      filetype = "blade",
    }

    require("nvim-treesitter.configs").setup(opts)
  end,
  dependencies = {
    -- "nvim-treesitter/nvim-treesitter-textobjects",
    -- "nvim-treesitter/nvim-treesitter-context",
    -- "nvim-treesitter/playground",
  },
}
