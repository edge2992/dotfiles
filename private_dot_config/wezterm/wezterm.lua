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
  config.native_macos_fullscreen_mode = true -- safe area を考慮した native fullscreen を使用
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

-- 全画面時だけ背景写真を敷く（native fullscreen で背面が黒潰れする問題への対処）
-- macOS 限定。Linux の全画面は 0.85 透過でデスクトップが透けるため挙動を変えない。
if is_macos then
  local BG_DIR = wezterm.config_dir .. "/backgrounds"

  -- backgrounds/ 内の画像を日付で 1 枚選ぶ
  -- （1 枚しか無ければ常にそれ／画像を足せば自動で日替わり）
  local function pick_daily_background()
    local ok, entries = pcall(wezterm.read_dir, BG_DIR)
    if not ok or not entries then
      return nil
    end
    local images = {}
    for _, path in ipairs(entries) do
      if path:match("%.jpe?g$") or path:match("%.png$") then
        table.insert(images, path)
      end
    end
    if #images == 0 then
      return nil
    end
    table.sort(images) -- 決定的に並べる
    local seed = tonumber(os.date("%Y%j")) or 0 -- 年 + 通算日 → 日替わり
    return images[(seed % #images) + 1]
  end

  local function apply_fullscreen_bg(window)
    if window:get_dimensions().is_full_screen then
      local img = pick_daily_background()
      if img then
        window:set_config_overrides({
          window_background_image = img,
          -- しっかり暗く（可読性優先）。brightness は 0.05〜0.10 で微調整可
          window_background_image_hsb = { brightness = 0.07, saturation = 1.0, hue = 1.0 },
          window_background_opacity = 1.0, -- 全画面では不透明にして写真をそのまま見せる
        })
        return
      end
    end
    -- 非全画面 or 画像なし: 既定（0.85 透過 + blur）へ戻す
    window:set_config_overrides({})
  end

  wezterm.on("window-resized", function(window, _pane)
    apply_fullscreen_bg(window)
  end)
  wezterm.on("window-config-reloaded", function(window, _pane)
    apply_fullscreen_bg(window)
  end)
end

return config
