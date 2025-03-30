if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  require("bigfile").setup {
    filesize = 1, -- Set threshold to 1 MiB
    pattern = function(bufnr, filesize_mib)
      local filename = vim.api.nvim_buf_get_name(bufnr)

      -- Enhanced pattern matching for minified/compressed files
      local is_minified = filename:match "%.min%.[^.]+$"
        or filename:match "%.[^.]+%.min$"
        or filename:match "%-min%.[^.]+$"
        or filename:match "%.[^.]+%-min$"
        or filename:match "%.bundle%.[^.]+$"
        or filename:match "%.[^.]+%.bundle$"
        or filename:match "%.pack%.[^.]+$"
        or filename:match "%.[^.]+%.pack$"
        or filename:match "%.gz$"
        or filename:match "%.brotli$"
        or filename:match "%.compiled%.[^.]+$"
        or filename:match "%.[^.]+%.compiled$"

      -- Check common minified file extensions
      local minified_extensions = { "js", "css", "html", "json", "xml", "vue" }
      local ext = filename:match "%.([^.]+)$"
      local is_common_type = ext and vim.tbl_contains(minified_extensions, ext:lower())

      -- Check file contents for minification indicators
      local function has_minified_content()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 20, false)
        local long_line_threshold = 500 -- Characters
        local wrap_threshold = 5 -- Number of wraps

        for _, line in ipairs(lines) do
          if #line > long_line_threshold then return true end
          if line:match "^%s*[!%(%){};:,%[%]]+" then return true end

          -- Count wraps (parentheses, braces, brackets)
          local open_count = select(2, line:gsub("[{%(%[]", ""))
          local close_count = select(2, line:gsub("[}%)%]]", ""))
          if open_count >= wrap_threshold or close_count >= wrap_threshold then return true end
        end
        return false
      end

      -- Adjust size thresholds
      local is_large_common_type = is_common_type and filesize_mib >= 0.1
      local is_very_large = filesize_mib >= 1

      -- Return true if any condition is met
      return is_minified or is_large_common_type or is_very_large or (is_common_type and has_minified_content())
    end,
    features = {
      "indent_blankline",
      "illuminate",
      "lsp",
      "treesitter",
      "syntax",
      "matchparen",
      "vimopts",
      "filetype",
    },
  },
}
