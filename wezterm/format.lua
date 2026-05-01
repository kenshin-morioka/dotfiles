local wezterm = require 'wezterm';

local function BaseName(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

-- ghq root を解決する。優先順位:
--   1. 環境変数 GHQ_ROOT
--   2. git config --global --get ghq.root
--   3. $HOME/ghq
local function resolve_ghq_root()
  local env_root = os.getenv('GHQ_ROOT')
  if env_root and #env_root > 0 then
    if env_root:sub(1, 1) == '~' then
      env_root = wezterm.home_dir .. env_root:sub(2)
    end
    return env_root
  end

  -- macOS の GUI 起動時は PATH に git が無い場合があるので候補を順に試す
  for _, git in ipairs({ 'git', '/opt/homebrew/bin/git', '/usr/local/bin/git', '/usr/bin/git' }) do
    local ok, stdout = wezterm.run_child_process({ git, 'config', '--global', '--get', 'ghq.root' })
    if ok and stdout then
      local root = stdout:gsub('%s+$', '')
      if root:sub(1, 1) == '~' then
        root = wezterm.home_dir .. root:sub(2)
      end
      if #root > 0 then return root end
    end
  end

  return wezterm.home_dir .. '/ghq'
end

local GHQ_ROOT = resolve_ghq_root()

local function pane_cwd_path(pane)
  local cwd = pane.current_working_dir
  if not cwd then return nil end
  if type(cwd) == 'string' then
    -- 古い wezterm では "file://host/path" 形式の文字列
    return (cwd:gsub('^file://[^/]*', ''))
  end
  return cwd.file_path
end

local function tab_label(pane)
  local fallback = (BaseName(pane.title))
  local path = pane_cwd_path(pane)
  if not path then return fallback end

  -- ghq root 配下なら <host>/<owner>/<repo> の repo を返す
  if path == GHQ_ROOT or path:sub(1, #GHQ_ROOT + 1) == GHQ_ROOT .. '/' then
    local rel = path:sub(#GHQ_ROOT + 2)
    local _host, _owner, repo = rel:match('^([^/]+)/([^/]+)/([^/]+)')
    if repo then return repo end
  end

  -- ghq root 取得に失敗した場合のフォールバック: <something>/<host.tld>/<owner>/<repo> を検出
  local repo = path:match('/[^/]+%.[^/]+/[^/]+/([^/]+)')
  if repo then return repo end

  -- $HOME を ~ に省略して表示
  local home = wezterm.home_dir
  if path == home then return '~' end
  if path:sub(1, #home + 1) == home .. '/' then
    return '~/' .. path:sub(#home + 2)
  end

  return fallback
end

wezterm.on(
  'format-window-title',
  function(tab)
    return BaseName(tab.active_pane.foreground_process_name)
  end
)

local HEADER = ''

local SYMBOL_COLOR = { '#ffb2cc', '#a4a4a4' }
local FONT_COLOR = { '#ecececff', '#c3c3c3ff' }
local BACK_COLOR = '#2d2d2d'
local HOVER_COLOR = '#434343'

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local index = tab.is_active and 1 or 2

    local bg = hover and HOVER_COLOR or BACK_COLOR
    local zoomed = tab.active_pane.is_zoomed and '🔎 ' or ' '

    return {
      { Foreground = { Color = SYMBOL_COLOR[index] } },
      { Background = { Color = bg } },
      { Text = HEADER .. zoomed },

      { Foreground = { Color = FONT_COLOR[index] } },
      { Background = { Color = bg } },
      { Text = tab_label(tab.active_pane) },
    }
  end
)
