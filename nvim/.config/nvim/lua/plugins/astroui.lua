-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    status = {
      colors = {
        buffer_active_bg = "#2A2F41",
      },
    },
    -- change colorscheme
    colorscheme = "tokyonight-night",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = {
        -- Normal = { bg = "#15131D" },
        -- NormalFloat = { bg = "#15131D" },
        -- NormalNC = { bg = "#15131D" },
        -- SignColumn = { bg = "#15131D" },
        -- StatusLine = { bg = "#1A1B26" },
        -- VertSplit = { bg = "#15131D" },
        -- TabLine = { bg = "#1A1B26" },
        -- TabLineFill = { bg = "#1A1B26" },
        -- TabLineSel = { bg = "#1A1B26" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        Normal = { bg = "#0D1116" },
        NormalFloat = { bg = "#0D1116" },
        NormalNC = { bg = "#0D1116" },
        SignColumn = { bg = "#0D1116" },
        StatusLine = { bg = "#020408" },
        VertSplit = { bg = "#0D1116" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
