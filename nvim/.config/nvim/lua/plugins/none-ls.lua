-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, config)
    -- config variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"
    local wp = require "wordpress"
    local lspconfig = require "lspconfig"

    lspconfig.intelephense.setup(wp.intelephense)

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    config.sources = {
      -- Set a formatter
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.diagnostics.phpcs.with(wp.null_ls_phpcs),
      -- phpcbf with PHP deprecation suppression
      -- BUG FIX: PHP 8.5+ deprecation warnings from composer deps (e.g. react/promise)
      -- were leaking into the formatted output and getting written as literal text
      -- at the top of PHP files on save. Two-layer fix:
      --   1) extra_args adds -d error_reporting=E_ALL&~E_DEPRECATED&~E_USER_DEPRECATED
      --      to suppress PHP deprecation notices at the source
      --   2) ignore_stderr discards any stderr output from phpcbf
      null_ls.builtins.formatting.phpcbf.with(vim.tbl_extend("force", wp.null_ls_phpcs, {
        extra_args = function(params)
          -- Call original wp.null_ls_phpcs.extra_args to get base args
          -- (-d memory_limit=1G, --standard=WordPress, etc.)
          local base_args = {}
          if type(wp.null_ls_phpcs.extra_args) == "function" then
            base_args = wp.null_ls_phpcs.extra_args(params) or {}
          elseif wp.null_ls_phpcs.extra_args then
            base_args = wp.null_ls_phpcs.extra_args
          end
          -- Append PHP ini directive to suppress deprecation warnings.
          -- This prevents PHP from emitting "Deprecated: Case statements..."
          -- messages that can leak into phpcbf's stdout and corrupt the buffer.
          vim.list_extend(base_args, {
            "-d",
            "error_reporting=E_ALL&~E_DEPRECATED&~E_USER_DEPRECATED",
          })
          return base_args
        end,
        ignore_stderr = true,
      })),
    }
    return config -- return final config table
  end,
}