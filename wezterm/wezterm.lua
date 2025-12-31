local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font_size = 12.0
config.use_ime = true
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
-- config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
-- config.show_close_tab_button_in_tabs = true

config.window_frame = {
  font = wezterm.font { family ='Roboto', weight = 'Bold' },
  font_size = 13.0,
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"

  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end

  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- keybindの設定
local keybind = require 'keybinds'
config.disable_default_key_bindings = true
config.keys = keybind.keys
config.key_tables = keybind.key_tables

-- background
local background = require 'background'
config.background = background

require 'format'
require 'status'
require 'event'


-- Leaderキーの設定
config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 2000 }

-- status
config.status_update_interval = 1000

-- mouse binds
-- config.mouse_bindings = require('mousebinds').mouse_bindings

return config
