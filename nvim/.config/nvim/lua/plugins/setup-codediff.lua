return {
  "esmuellert/codediff.nvim",
  event = "User AstroGitFile",
  cmd = "CodeDiff",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    diff = {
      layout = "inline",
    },
    explorer = {
      width = 20,
    },
  },
}
