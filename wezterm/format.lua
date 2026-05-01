local wezterm = require 'wezterm';

local function BaseName(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local function expand_tilde(p)
  if p:sub(1, 1) == '~' then
    return wezterm.home_dir .. p:sub(2)
  end
  return p
end

local function read_file(path)
  local f = io.open(path, 'r')
  if not f then return nil end
  local content = f:read('*a')
  f:close()
  return content
end

-- gitconfig を再帰的に走査して [ghq] root を探す。include の循環は visited で防ぐ。
local function find_ghq_root_in_gitconfig(path, depth, visited)
  if depth > 5 then return nil end
  visited = visited or {}
  if visited[path] then return nil end
  visited[path] = true

  local content = read_file(path)
  if not content then return nil end

  local section
  local includes = {}
  for line in content:gmatch('[^\n]+') do
    local s = line:match('^%s*%[([^%]]+)%]')
    if s then
      section = s:gsub('%s.*', '')
    elseif section == 'ghq' then
      local root = line:match('^%s*root%s*=%s*(.-)%s*$')
      if root and #root > 0 then
        root = root:gsub('^"(.*)"$', '%1'):gsub("^'(.*)'$", '%1')
        return expand_tilde(root)
      end
    elseif section == 'include' then
      local inc = line:match('^%s*path%s*=%s*(.-)%s*$')
      if inc and #inc > 0 then
        table.insert(includes, expand_tilde(inc))
      end
    end
  end

  for _, inc in ipairs(includes) do
    local r = find_ghq_root_in_gitconfig(inc, depth + 1, visited)
    if r then return r end
  end

  return nil
end

-- ghq root を解決する。優先順位:
--   1. 環境変数 GHQ_ROOT
--   2. ~/.gitconfig / ~/.config/git/config の [ghq] root（include も追跡）
--   3. $HOME/ghq
-- run_child_process は config 読み込み中は coroutine 外で yield 不能なため使わない。
local function resolve_ghq_root()
  local env_root = os.getenv('GHQ_ROOT')
  if env_root and #env_root > 0 then
    return expand_tilde(env_root)
  end

  for _, path in ipairs({
    wezterm.home_dir .. '/.gitconfig',
    wezterm.home_dir .. '/.config/git/config',
  }) do
    local r = find_ghq_root_in_gitconfig(path, 0, nil)
    if r then return r end
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

local M = {}

function M.tab_label(pane)
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

return M
