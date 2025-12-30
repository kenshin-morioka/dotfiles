local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font_size = 12.0
config.use_ime = true
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true

config.window_frame = {
  font = wezterm.font { family ='Roboto', weight = 'Bold' },
  font_size = 11.0,
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

config.show_new_tab_button_in_tab_bar = false
-- config.show_close_tab_button_in_tabs = true

require 'format'
require 'status'
require 'event'
require 'keybinds'


local keybind = require 'keybinds'
local background = require 'background'

-- keybinds
-- デフォルトのkeybindを無効化
config.disable_default_key_bindings = true

-- keybindの設定
config.keys = keybind.keys
config.key_tables = keybind.key_tables

-- Leaderキーの設定
config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 2000 }

-- status
config.status_update_interval = 1000

-- background
config.background = background

-- mouse binds
-- config.mouse_bindings = require('mousebinds').mouse_bindings

return config
