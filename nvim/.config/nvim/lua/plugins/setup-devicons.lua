return {
  "nvim-tree/nvim-web-devicons",
  opts = {
    override = {
      blade = {
        icon = "󰫐",
        name = "Blade",
        color = "#c24a46",
      },
      ["blade.php"] = {
        icon = "󰫐",
        name = "Blade",
        color = "#c24a46",
      },
    },
    override_by_filename = {
      [".blade.php"] = {
        icon = "󰫐",
        name = "Blade",
        color = "#c24a46",
      },
    },
    override_by_extension = {
      ["blade"] = {
        icon = "󰫐",
        name = "Blade",
        color = "#c24a46",
      },
    },
  },
}
