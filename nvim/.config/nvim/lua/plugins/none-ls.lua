-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize None-ls sources
-- All WordPress-specific config is inlined here — no dependency on wordpress.nvim plugin.

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, config)
    local null_ls = require "null-ls"
    local h = require "null-ls.helpers"
    local lspconfig = require "lspconfig"
    local methods = require "null-ls.methods"

    local FORMATTING = methods.internal.FORMATTING
    local DIAGNOSTICS = methods.internal.DIAGNOSTICS

    -- Intelephense with WordPress stubs (inlined from wordpress.nvim)
    lspconfig.intelephense.setup {
      get_language_id = function() return "php" end,
      filetypes = { "php", "php.wp" },
      settings = {
        intelephense = {
          stubs = {
            "apache", "bcmath", "bz2", "calendar", "com_dotnet", "Core",
            "ctype", "curl", "date", "dba", "dom", "enchant", "exif", "FFI",
            "fileinfo", "filter", "fpm", "ftp", "gd", "gettext", "gmp", "hash",
            "iconv", "imap", "intl", "json", "ldap", "libxml", "mbstring",
            "meta", "mysqli", "oci8", "odbc", "openssl", "pcntl", "pcre", "PDO",
            "pdo_ibm", "pdo_mysql", "pdo_pgsql", "pdo_sqlite", "pgsql", "Phar",
            "posix", "pspell", "readline", "Reflection", "session", "shmop",
            "SimpleXML", "snmp", "soap", "sockets", "sodium", "SPL", "sqlite3",
            "standard", "superglobals", "sysvmsg", "sysvsem", "sysvshm", "tidy",
            "tokenizer", "xml", "xmlreader", "xmlrpc", "xmlwriter", "xsl",
            "Zend OPcache", "zip", "zlib", "wordpress", "memcache", "memcached",
            "phpunit",
          },
          files = { maxSize = 5000000 },
        },
      },
    }

    -- PHPCS root pattern for finding local config
    local phpcs_root_pattern = require("null-ls.utils").root_pattern(
      "phpcs.xml.dist", "phpcs.xml", ".phpcs.xml.dist", ".phpcs.xml"
    )

    -- Build phpcbf/phpcs extra args with WordPress standards + deprecation suppression
    local function wp_extra_args(params)
      local args = { "-d", "memory_limit=1G" }
      if params.ft == "php.wp" then
        local local_root = phpcs_root_pattern(params.bufname)
        if not local_root then
          table.insert(args, "--standard=WordPress")
        end
      end
      vim.list_extend(args, {
        "-d", "error_reporting=E_ALL&~E_DEPRECATED&~E_USER_DEPRECATED",
      })
      return args
    end

    local function wp_cwd(params)
      local local_root = phpcs_root_pattern(params.bufname)
      return local_root or params.root
    end

    -- Custom phpcbf source built with generator_factory (NOT formatter_factory)
    -- so we control on_output and can strip PHP deprecation warnings from stdout.
    -- formatter_factory always overwrites on_output, making it impossible to
    -- filter garbage lines before they reach the buffer.
    local phpcbf_source = h.make_builtin({
      name = "phpcbf",
      method = FORMATTING,
      filetypes = { "php", "php.wp" },
      generator_opts = {
        command = "phpcbf",
        args = function(params)
          local base = { "-q", "--stdin-path=$FILENAME", "-" }
          local extra = wp_extra_args(params) or {}
          -- keep "-" as last arg
          table.remove(base, #base)
          local merged = vim.list_extend(base, extra)
          table.insert(merged, "-")
          return merged
        end,
        to_stdin = true,
        cwd = wp_cwd,
        timeout = 15000,
        check_exit_code = function(code)
          return code <= 2
        end,
        ignore_stderr = true,
        on_output = function(params, done)
          local output = params.output
          if not output then return done() end
          -- Strip PHP diagnostic lines that leaked into stdout.
          -- PHP deprecation notices (e.g. from react/promise on PHP 8.5+)
          -- are printed to stdout before the formatted code, causing them
          -- to be literally written into the buffer as file content.
          local lines = vim.split(output, "\n")
          local cleaned = {}
          for _, line in ipairs(lines) do
            if not line:match("^Deprecated:%s")
              and not line:match("^Notice:%s")
              and not line:match("^Warning:%s")
              and not line:match("^Fatal error:%s")
              and not line:match("^Parse error:%s")
            then
              table.insert(cleaned, line)
            end
          end
          local result = table.concat(cleaned, "\n")
          if output:sub(-1) == "\n" and result:sub(-1) ~= "\n" then
            result = result .. "\n"
          end
          return done({ { text = result } })
        end,
      },
      factory = h.generator_factory,
    })

    config.sources = {
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.prettierd,
      -- PHPCS diagnostics (WordPress coding standards for php.wp files)
      null_ls.builtins.diagnostics.phpcs.with {
        timeout = 15000,
        extra_args = wp_extra_args,
        cwd = wp_cwd,
        ignore_stderr = true,
      },
      -- PHPCBF formatter — custom source using generator_factory directly
      -- to control on_output and strip deprecation warnings from stdout.
      phpcbf_source,
    }
    return config
  end,
}