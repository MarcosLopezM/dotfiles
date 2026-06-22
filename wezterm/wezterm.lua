local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Font Settings
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"Symbols Nerd Font",
})
config.font_size = 10.0
config.line_height = 1.2

-- Theme Settings
local color_scheme = "cyberdream"
config.color_schemes = { ["cyberdream"] = require("cyberdream") }
config.color_scheme = color_scheme
config.term = "wezterm"

-- Cyberdream color palette
local scheme_colors = {
	cyberdream = {
		background = "#16181a",
		foreground = "#ffffff",
		black = "#16181a",
		red = "#ff6e5e",
		green = "#5eff6c",
		yellow = "#f1ff5e",
		blue = "#5ea1ff",
		purple = "#bd5eff",
		cyan = "#5ef1ff",
		white = "#ffffff",
		gray = "#3c4048",
		orange = "#ffbd5e",
	},
}

-- Appearance
config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.tab_and_split_indices_are_zero_based = true

config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.85
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 10,
	right = 0,
	top = 0,
	bottom = 0,
}

config.window_frame = {
	font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Bold" }),
	font_size = 9.5,
	active_titlebar_bg = scheme_colors.cyberdream.background,
	inactive_titlebar_bg = scheme_colors.cyberdream.background,
}

config.colors = {
	tab_bar = {
		background = scheme_colors.cyberdream.background,
		active_tab = {
			bg_color = scheme_colors.cyberdream.cyan,
			fg_color = scheme_colors.cyberdream.background,
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = scheme_colors.cyberdream.background,
			fg_color = scheme_colors.cyberdream.gray,
		},
		inactive_tab_hover = {
			bg_color = scheme_colors.cyberdream.gray,
			fg_color = scheme_colors.cyberdream.white,
			italic = true,
		},
		new_tab = {
			bg_color = scheme_colors.cyberdream.gray,
			fg_color = scheme_colors.cyberdream.white,
		},
		new_tab_hover = {
			bg_color = scheme_colors.cyberdream.gray,
			fg_color = scheme_colors.cyberdream.white,
		},
	},
}

local leader_prefix = wezterm.nerdfonts.fae_atom
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- Keybindings
local act = wezterm.action
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 500 }
config.keys = {
	-- Splits
	{ key = "-", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	--Resize panes
	{ key = "LeftArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "UpArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "RightArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "DownArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Down", 5 }) },

	-- Pane navigation
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },

	-- Close pane
	{ key = "x", mods = "ALT", action = act.CloseCurrentPane({ confirm = true }) },

	-- Tabs
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ mods = "LEADER", key = "b", action = act.ActivateTabRelative(-1) },
	{ mods = "LEADER", key = "n", action = act.ActivateTabRelative(1) },
}

-- Activate tab
for i = 0, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL",
		action = act.ActivateTab(i),
	})
end

-- Tabs
local function trim_to_last(title)
	title = title:gsub("/$", "")
	return title:match("([^/\\]+)$") or title
end

local function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return trim_to_last(title)
	end

	return trim_to_last(tab_info.active_pane.title)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = "" .. tab.tab_index .. ": " .. tab_title(tab) .. ""
	title = wezterm.truncate_right(title, max_width)

	return title
end)

wezterm.on("update-status", function(window, _)
	if window:leader_is_active() then
		window:set_left_status(wezterm.format({
			{ Background = { Color = scheme_colors.cyberdream.green } },
			{ Foreground = { Color = scheme_colors.cyberdream.background } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " " .. leader_prefix .. " " },
		}))
	else
		window:set_left_status(wezterm.format({
			{ Background = { Color = scheme_colors.cyberdream.background } },
			{ Text = " " },
		}))
	end
end)

-- WSL
config.default_domain = "WSL:Ubuntu-24.04"

-- Miscellanous setting
config.max_fps = 120
config.animation_fps = 120
config.prefer_egl = true

return config
