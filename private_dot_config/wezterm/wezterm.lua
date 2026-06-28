local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- 実行時 OS 判定（chezmoi テンプレートではなく WezTerm 側で分岐）
local is_macos = wezterm.target_triple:find("darwin") ~= nil

-- Font
config.font = wezterm.font("UDEV Gothic NF")
config.font_size = 12.0

-- Appearance
config.color_scheme = "Tokyo Night"
config.term = "xterm-256color"
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.window_background_opacity = 0.85
config.scrollback_lines = 200
config.automatically_reload_config = true
if is_macos then
  -- macOS 専用。Linux では無視されるため OS でガードしておく
  config.macos_window_background_blur = 20
end

-- IME（Linux: fcitx）。既存設定を保持
config.use_ime = true
config.xim_im_name = "fcitx"
config.ime_preedit_rendering = "Builtin"

-- Keybinds
-- 方針: pane/window/copy 等の tmux 的操作は WezTerm に置かない。
-- ここで定義するのは「IME トグルを通すための既定無効化」と
-- 「外部モニター対策のフォントサイズ調整」のみ。
config.keys = {
  -- Ctrl+Space を端末（fcitx 等）へ通すため既定割当を無効化（既存維持）
  { key = " ", mods = "CTRL", action = act.DisableDefaultAssignment },
}

-- フォントサイズ調整（OS 別の修飾キー）
-- macOS: Cmd(SUPER) / Linux: Ctrl+Shift
-- "+" "_" ")" は Shift 併用時に生成される字形も拾えるよう両方登録して堅牢化
local font_keys
if is_macos then
  font_keys = {
    { key = "+", mods = "SUPER", action = act.IncreaseFontSize },
    { key = "=", mods = "SUPER", action = act.IncreaseFontSize },
    { key = "-", mods = "SUPER", action = act.DecreaseFontSize },
    { key = "0", mods = "SUPER", action = act.ResetFontSize },
  }
else
  font_keys = {
    { key = "+", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
    { key = "=", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
    { key = "_", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL|SHIFT", action = act.ResetFontSize },
    { key = ")", mods = "CTRL|SHIFT", action = act.ResetFontSize },
  }
end
for _, k in ipairs(font_keys) do
  table.insert(config.keys, k)
end

return config
