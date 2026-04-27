-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize None-ls sources
-- All WordPress-specific config is inlined here — no dependency on wordpress.nvim plugin.

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, config)
    local null_ls = require "null-ls"
    local lspconfig = require "lspconfig"

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

    -- PHPCS root pattern for finding local config (inlined from wordpress.nvim)
    local phpcs_root_pattern = require("null-ls.utils").root_pattern(
      "phpcs.xml.dist", "phpcs.xml", ".phpcs.xml.dist", ".phpcs.xml"
    )

    -- Shared phpcbf/phpcs args builder (inlined from wordpress.nvim)
    -- Adds WordPress coding standard + PHP deprecation suppression for php.wp files
    local function wp_extra_args(params)
      local args = { "-d", "memory_limit=1G" }
      if params.ft == "php.wp" then
        local local_root = phpcs_root_pattern(params.bufname)
        if not local_root then
          table.insert(args, "--standard=WordPress")
        end
      end
      -- Suppress PHP deprecation warnings that would leak into phpcbf stdout
      vim.list_extend(args, {
        "-d", "error_reporting=E_ALL&~E_DEPRECATED&~E_USER_DEPRECATED",
      })
      return args
    end

    local function wp_cwd(params)
      local local_root = phpcs_root_pattern(params.bufname)
      return local_root or params.root
    end

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
      -- PHPCBF formatter
      -- PHP deprecation warnings (e.g. from react/promise on PHP 8.5+) can
      -- leak into phpcbf's stdout. none-ls formatter_factory passes ALL stdout
      -- as formatted text, so we override on_output to strip them.
      null_ls.builtins.formatting.phpcbf.with {
        timeout = 15000,
        extra_args = wp_extra_args,
        cwd = wp_cwd,
        ignore_stderr = true,
        on_output = function(params, done)
          local output = params.output
          if not output then return done() end
          -- Strip PHP diagnostic lines from stdout before using as formatted text.
          -- These warnings should never appear in formatted output — they are
          -- side-effects of the PHP interpreter running phpcbf, not part of
          -- the code itself.
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
    }
    return config
  end,
}