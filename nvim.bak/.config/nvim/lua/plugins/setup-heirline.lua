if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"

    -- Define the CodeCompanion component
    local CodeCompanion = {
      static = {
        processing = false,
      },
      update = {
        "User",
        pattern = "CodeCompanionRequest*",
        callback = function(self, args)
          if args.match == "CodeCompanionRequestStarted" then
            self.processing = true
          elseif args.match == "CodeCompanionRequestFinished" then
            self.processing = false
          end
          vim.cmd "redrawstatus"
        end,
      },
      {
        condition = function(self) return self.processing end,
        provider = " ",
        hl = { fg = "yellow" },
      },
    }

    opts.statusline = { -- statusline
      hl = { fg = "fg", bg = "bg" },
      status.component.mode(),
      status.component.file_info(),
      status.component.diagnostics(),
      CodeCompanion,
      status.component.fill(),
      status.component.fill(),
      status.component.virtual_env(),
      status.component.treesitter(),
      status.component.nav(),
      status.component.mode { surround = { separator = "right" } },
    }
  end,
}
