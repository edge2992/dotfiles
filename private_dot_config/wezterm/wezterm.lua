local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("UDEV Gothic NF")
config.font_size = 12.0
config.color_scheme = "Tokyo Night"
config.term = "xterm-256color"
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.window_background_opacity = 0.95
config.scrollback_lines = 200
config.use_ime = true
config.xim_im_name = "fcitx"
config.ime_preedit_rendering = "Builtin"

config.keys = {
  {
    key = " ",
    mods = "CTRL",
    action = wezterm.action.DisableDefaultAssignment,
  },
}

return config
