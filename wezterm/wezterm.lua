require 'format'
require 'status'
require 'event'
require 'keybinds'

local wezterm = require 'wezterm';

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- keybinds
-- デフォルトのkeybindを無効化
config.disable_default_key_bindings = true
-- `keybinds.lua`を読み込み
local keybind = require 'keybinds'
-- keybindの設定
config.keys = keybind.keys
config.key_tables = keybind.key_tables
-- Leaderキーの設定
config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 2000 }

-- colors
config.color_scheme = "nord"
config.window_background_opacity = 0.93

-- font
config.font = require("wezterm").font("Menlo for Powerline")
config.font_size = 16.0
config.window_frame = {
  font = wezterm.font { family ='Roboto', weight = 'Bold' },
  font_size = 11.0,
}

-- status
config.status_update_interval = 1000

-- window decorations
config.window_decorations = "RESIZE"

-- mouse binds
config.mouse_bindings = require('mousebinds').mouse_bindings

return config

