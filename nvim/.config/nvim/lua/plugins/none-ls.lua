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
      -- phpcbf: suppress PHP deprecation warnings (e.g. from react/promise on PHP 8.5+)
      -- that could leak into stdout and end up written into the buffer as literal text.
      -- Two-layer defense:
      --   extra_args: -d error_reporting=...  → prevents PHP from emitting deprecation notices
      --   ignore_stderr: true  → discards any stderr output
      null_ls.builtins.formatting.phpcbf.with(vim.tbl_extend("force", wp.null_ls_phpcs, {
        extra_args = function(params)
          local base_args = {}
          if type(wp.null_ls_phpcs.extra_args) == "function" then
            base_args = wp.null_ls_phpcs.extra_args(params) or {}
          elseif wp.null_ls_phpcs.extra_args then
            base_args = wp.null_ls_phpcs.extra_args
          end
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