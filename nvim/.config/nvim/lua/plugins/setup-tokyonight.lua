-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "folke/tokyonight.nvim",
  opts = {
    style = "night",
    styles = {
      functions = {},
    },
    on_colors = function(colors)
      -- colors.bg = "#15131D"
      -- colors.bg_dark = "#15131D"
    end,
    on_highlights = function(highlights, colors)
      highlights.Normal = { bg = "#0A0912" }
      highlights.NormalFloat = { bg = "#0A0912" }
      highlights.NormalNC = { bg = "#0A0912" }
      highlights.SignColumn = { bg = "#0A0912" }
      highlights.StatusLine = { bg = "#1A1B26" }
      highlights.VertSplit = { bg = "#0A0912" }
      highlights.TabLine = { bg = "#1A1B26" }
      highlights.TabLineFill = { bg = "#1A1B26" }
      highlights.TabLineSel = { bg = "#1A1B26" }
    end,
  },
}