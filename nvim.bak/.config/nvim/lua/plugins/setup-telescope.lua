if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  require("telescope").setup {
    pickers = {
      current_buffer_fuzzy_find = {
        previewer = false,
      },
    },
  },
}
