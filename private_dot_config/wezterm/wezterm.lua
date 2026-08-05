local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- 実行時 OS 判定（chezmoi テンプレートではなく WezTerm 側で分岐）
local is_macos = wezterm.target_triple:find("darwin") ~= nil

-- Font
config.font = wezterm.font("UDEV Gothic NF")
config.font_size = 12.0

-- ディスプレイ解像度ごとのフォントサイズ上書き
-- 2K(WQHD) 外部モニターの全画面では 12pt が小さすぎるため少し拡大する。
-- キーは wezterm.gui.screens().active が返す物理ピクセルの "幅x高さ"。
-- 表にない解像度（内蔵 Retina 等）は config.font_size のまま。
local FONT_SIZE_BY_RESOLUTION = {
  ["2560x1440"] = 14.0, -- 2K / WQHD 外部モニター
}

local function font_size_for_active_screen()
  -- 注意: screens().active は「入力フォーカスのある画面」。複数モニタに複数ウィンドウを
  -- 開いていると、フォーカス外のウィンドウにはフォーカス側画面のサイズが適用されうる
  -- （通常の単一ウィンドウ運用では問題にならない既知の制約）
  -- mux server など GUI の無いコンテキストでは wezterm.gui が使えないため pcall で保護
  local ok, screens = pcall(function()
    return wezterm.gui.screens()
  end)
  if not ok or not screens or not screens.active then
    return nil
  end
  local key = string.format("%dx%d", screens.active.width, screens.active.height)
  return FONT_SIZE_BY_RESOLUTION[key]
end

-- Appearance
-- Tokyo Night の bright black（chalk.gray 等が使う ANSI 8）は背景とのコントラストが
-- 低く（#414868 対 #1a1b26 で約1.9:1）、ccusage や takt が gray で出す補足情報が
-- 読みにくいため、その1色だけ明るく上書きする（背景比 約4.4:1）。
local tokyo_night = wezterm.color.get_builtin_schemes()["Tokyo Night"]
tokyo_night.brights[1] = "#7c818c"
config.color_schemes = { ["Tokyo Night"] = tokyo_night }
config.color_scheme = "Tokyo Night"
config.term = "xterm-256color"
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.window_background_opacity = 0.85
-- 背景色付きセル(nvim の CursorLine 等)も透過させ、浮きを防ぐ。
-- 0.85 では全画面時の暗い背景写真がほぼ透けず体感差が無かった。
-- 全画面相当の条件(背景写真+不透明)で 0.3/0.45/0.6 を目視比較して 0.45 を採用。
config.text_background_opacity = 0.45
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
-- 方針: pane/tab 等の tmux 的操作は WezTerm に置かない。
-- ここで定義するのは「IME トグルを通すための既定無効化」「外部モニター対策の
-- フォントサイズ調整」、および「複数ディスプレイに広げた WezTerm ウィンドウ間の
-- フォーカス切替」のみ。ウィンドウ間切替は tmux の管轄外（tmux は1ウィンドウ内の
-- pane/window しか扱えない）なので、この方針と矛盾しない。
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

-- ウィンドウフォーカス切替（複数ディスプレイに広げた WezTerm ウィンドウ間）
-- macOS: Cmd(SUPER) / Linux: Ctrl+Shift（フォントサイズ調整と同じ修飾キー方針）
-- ] で次のウィンドウへ、[ で前のウィンドウへ（端まで来たら反対側へ折り返す）
local window_keys
if is_macos then
  window_keys = {
    { key = "]", mods = "SUPER", action = act.ActivateWindowRelative(1) },
    { key = "[", mods = "SUPER", action = act.ActivateWindowRelative(-1) },
  }
else
  window_keys = {
    { key = "]", mods = "CTRL|SHIFT", action = act.ActivateWindowRelative(1) },
    { key = "[", mods = "CTRL|SHIFT", action = act.ActivateWindowRelative(-1) },
  }
end
for _, k in ipairs(window_keys) do
  table.insert(config.keys, k)
end

-- ウィンドウ状態に応じた動的設定（config overrides）
-- - フォントサイズ: アクティブディスプレイの解像度で切替（全 OS）
-- - 背景写真: 全画面時だけ敷く（macOS 限定。native fullscreen で背面が黒潰れする
--   問題への対処。Linux の全画面は 0.85 透過でデスクトップが透けるため挙動を変えない）
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

local function compute_overrides(window)
  local overrides = {}

  local size = font_size_for_active_screen()
  if size then
    overrides.font_size = size
  end

  if is_macos and window:get_dimensions().is_full_screen then
    local img = pick_daily_background()
    if img then
      overrides.window_background_image = img
      -- しっかり暗く（可読性優先）。brightness は 0.05〜0.10 で微調整可
      overrides.window_background_image_hsb = { brightness = 0.07, saturation = 1.0, hue = 1.0 }
      overrides.window_background_opacity = 1.0 -- 全画面では不透明にして写真をそのまま見せる
    end
  end

  return overrides
end

local function apply_overrides(window)
  local current = window:get_config_overrides() or {}
  local new = compute_overrides(window)
  -- 変化が無いときは set_config_overrides を呼ばない
  -- （window-config-reloaded が再発火して無限ループになるのを防ぐ）。
  -- 前提: hsb / opacity は image の有無に連動する定数なので代表キー比較で足りる。
  -- hsb 等を独立に変化させる変更を入れる場合は、この比較にそのキーも追加すること
  -- （テーブルの参照比較は毎回不一致→無限ループになるためフィールド単位で比較する）。
  if current.font_size == new.font_size and current.window_background_image == new.window_background_image then
    return
  end
  window:set_config_overrides(new)
end

wezterm.on("window-resized", function(window, _pane)
  apply_overrides(window)
end)
wezterm.on("window-config-reloaded", function(window, _pane)
  apply_overrides(window)
end)

return config
