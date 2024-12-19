-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
--
--

return {
  require("blink-cmp").setup {
    keymap = {
      -- Manually invoke minuet completion.
      --
      -- To enable manual completion, you must use the nightly version of
      -- `blink-cmp`. The latest tagged release (v0.7.6, at the time of
      -- writing) does not yet support this feature. Additionally, you need
      -- to set the `min_keyword_length` option in `blink-cmp` to 0 to get
      -- manual completion work until the issue tracked at
      -- https://github.com/Saghen/blink.cmp/issues/647 is resolved.
      ["<A-y>"] = {
        function(cmp) cmp.show { providers = { "minuet" } } end,
      },
    },
    sources = {
      -- Enable minuet for autocomplete
      default = { "lsp", "path", "buffer", "snippets", "minuet" },
      -- For manual completion only, remove 'minuet' from default
      providers = {
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          score_offset = 8, -- Gives minuet higher priority among suggestions
        },
      },
    },
  },
}
