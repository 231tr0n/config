local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font_size = 12
config.enable_scroll_bar = false
config.enable_tab_bar = false
config.font = wezterm.font_with_fallback({
	"RobotoMono Nerd Font Propo",
	"IosevkaTerm Nerd Font Propo",
})
config.colors = {
	background = "#2D353B",
	cursor_bg = "#D3C6AA",
	cursor_border = "#D3C6AA",
	cursor_fg = "#2D353B",
	foreground = "#D3C6AA",
	ansi = {
		"#475258",
		"#E67E80",
		"#A7C080",
		"#DBBC7F",
		"#7FBBB3",
		"#D699B6",
		"#83C092",
		"#D3C6AA",
	},
	brights = {
		"#475258",
		"#E67E80",
		"#A7C080",
		"#DBBC7F",
		"#7FBBB3",
		"#D699B6",
		"#83C092",
		"#D3C6AA",
	},
}
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

return config
