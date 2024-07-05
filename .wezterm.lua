-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
-- This will hold the configuration.
local config = wezterm.config_builder()
config.dpi = 144
-- This is where you actually apply your config choices
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.window_close_confirmation = "NeverPrompt"
-- Updated color scheme (Tokyo Night)
config.colors = {
	foreground = "#c0caf5",
	background = "#0a0912",
	cursor_bg = "#c0caf5",
	cursor_border = "#c0caf5",
	cursor_fg = "#1a1b26",
	selection_bg = "#283457",
	selection_fg = "#c0caf5",
	split = "#7aa2f7",
	compose_cursor = "#ff9e64",
	scrollbar_thumb = "#292e42",

	ansi = {
		"#15161e",
		"#f7768e",
		"#9ece6a",
		"#e0af68",
		"#7aa2f7",
		"#bb9af7",
		"#7dcfff",
		"#a9b1d6",
	},
	brights = {
		"#414868",
		"#f7768e",
		"#9ece6a",
		"#e0af68",
		"#7aa2f7",
		"#bb9af7",
		"#7dcfff",
		"#c0caf5",
	},
}

-- Keeping your existing font settings
config.font = wezterm.font("FiraCode NF", { weight = "Medium" })
config.font_size = 14
config.line_height = 1.4

-- Keeping your existing tab bar setting
config.enable_tab_bar = false

-- Keeping your existing window settings
config.window_decorations = "RESIZE"
config.native_macos_fullscreen_mode = true
-- config.window_background_opacity = 0.75
-- config.macos_window_background_blur = 8

-- New tab bar colors (if you decide to enable the tab bar in the future)
config.colors.tab_bar = {
	inactive_tab_edge = "#16161e",
	background = "#1a1b26",
	active_tab = {
		fg_color = "#16161e",
		bg_color = "#7aa2f7",
	},
	inactive_tab = {
		fg_color = "#545c7e",
		bg_color = "#292e42",
	},
	inactive_tab_hover = {
		fg_color = "#7aa2f7",
		bg_color = "#292e42",
		-- intensity = "Bold"
	},
	new_tab_hover = {
		fg_color = "#7aa2f7",
		bg_color = "#1a1b26",
		intensity = "Bold",
	},
	new_tab = {
		fg_color = "#7aa2f7",
		bg_color = "#1a1b26",
	},
}

config.keys = {
	-- Clears only the scrollback and leaves the viewport intact.
	-- You won't see a difference in what is on screen, you just won't
	-- be able to scroll back until you've output more stuff on screen.
	-- This is the default behavior.
	{
		key = "k",
		mods = "CMD",
		action = act.ClearScrollback("ScrollbackOnly"),
	},
	-- Clears the scrollback and viewport leaving the prompt line the new first line.
	{
		key = "k",
		mods = "CMD",
		action = act.ClearScrollback("ScrollbackAndViewport"),
	},
	-- Clears the scrollback and viewport, and then sends CTRL-L to ask the
	-- shell to redraw its prompt
	{
		key = "k",
		mods = "CMD",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "L", mods = "CTRL" }),
		}),
	},
}

-- and finally, return the configuration to wezterm
return config
