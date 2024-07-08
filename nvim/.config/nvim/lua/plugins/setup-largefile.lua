return {
  require("bigfile").setup {
    filesize = 1, -- in MB
    pattern = function(bufnr, filesize_mib)
      -- Custom logic to determine if a file is "big"
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local avg_line_length = filesize_mib * 1024 * 1024 / line_count -- Convert MiB to bytes

      -- Consider a file "big" if it's larger than 1MB or has very long lines on average
      return filesize_mib > 1 or avg_line_length > vim.o.synmaxcol
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
