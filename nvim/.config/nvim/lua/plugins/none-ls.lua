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
      -- phpcbf: PHP deprecation warnings (e.g. from react/promise on PHP 8.5+)
      -- can leak into phpcbf's stdout. none-ls formatter_factory passes ALL stdout
      -- directly as formatted text, so these warnings end up literally written
      -- into the buffer. Three layers of defense:
      --   1. on_output: strips any "Deprecated:" lines from phpcbf stdout (guaranteed fix)
      --   2. extra_args with -d error_reporting: tells PHP not to emit deprecation notices
      --   3. ignore_stderr: discards stderr output (belt-and-suspenders)
      null_ls.builtins.formatting.phpcbf.with(vim.tbl_extend("force", wp.null_ls_phpcs, {
        extra_args = function(params)
          local base_args = {}
          if type(wp.null_ls_phpcs.extra_args) == "function" then
            base_args = wp.null_ls_phpcs.extra_args(params) or {}
          elseif wp.null_ls_phpcs.extra_args then
            base_args = wp.null_ls_phpcs.extra_args
          end
          -- Always add deprecation suppression, not just for php.wp
          vim.list_extend(base_args, {
            "-d",
            "error_reporting=E_ALL&~E_DEPRECATED&~E_USER_DEPRECATED",
          })
          return base_args
        end,
        ignore_stderr = true,
        -- Override on_output to strip PHP deprecation/notice lines that leaked
        -- into stdout. This is the guaranteed fix: even if -d error_reporting
        -- doesn't reach the PHP interpreter (e.g. because phpcbf is a phar
        -- wrapper), we strip the garbage lines before they reach the buffer.
        on_output = function(params, done)
          local output = params.output
          if not output then return done() end
          -- Remove lines starting with PHP severity keywords that shouldn't
          -- be in formatted output: Deprecated, Notice, Warning, Fatal error, etc.
          local lines = vim.split(output, "\n")
          local cleaned = {}
          for _, line in ipairs(lines) do
            if not line:match("^Deprecated:%s") and not line:match("^Notice:%s") and not line:match("^Warning:%s") and not line:match("^Fatal error:%s") and not line:match("^Parse error:%s") then
              table.insert(cleaned, line)
            end
          end
          -- Rejoin with newlines; handle trailing newline preservation
          local result = table.concat(cleaned, "\n")
          -- Preserve original trailing newline behavior
          if output:sub(-1) == "\n" and result:sub(-1) ~= "\n" then
            result = result .. "\n"
          end
          return done({ { text = result } })
        end,
      })),
    }
    return config -- return final config table
  end,
}