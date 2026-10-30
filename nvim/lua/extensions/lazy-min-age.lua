-- lazy.nvim の更新先を、公開から一定時間たったコミット・タグに限定する (サプライチェーン攻撃対策)
-- lazy.nvim 内部の Git.get_target を差し替えている。上流に minimum_release_age
-- (https://github.com/folke/lazy.nvim/pull/2159) が入ったらそちらに置き換える
-- 経過時間はコミット日時・タグ作成日時で判定するため、日時を偽装したコミットは防げない
local Config = require("lazy.core.config")
local Git = require("lazy.manage.git")
local Process = require("lazy.manage.process")
local Semver = require("lazy.manage.semver")

local MIN_AGE = 2 * 24 * 60 * 60

--- 失敗時は nil、成功時は空行を除いた出力行を返す
--- 失敗時は呼び出し側で今のコミットに留める (更新しない側に倒す)。git の失敗自体は lazy の fetch 等で表面化する
---@return string[]?
local function git(dir, args)
  local lines, code = Process.exec(vim.list_extend({ "git" }, args), { cwd = dir })
  if code ~= 0 then
    return nil
  end
  return vim.tbl_filter(function(line)
    return line ~= ""
  end, lines)
end

--- range の first-parent 履歴のうち cutoff 以前の最新コミット
local function aged_commit(dir, range, cutoff)
  local out = git(dir, { "log", "-1", "--first-parent", "--format=%H", "--before=@" .. cutoff, range })
  return out and out[1]
end

--- version 指定に合うタグのうち cutoff 以前に作成された最新のもの
local function aged_version(plugin, cutoff)
  local dates = {}
  for _, line in ipairs(git(plugin.dir, { "for-each-ref", "--format=%(refname:strip=2) %(creatordate:unix)", "refs/tags" }) or {}) do
    local tag, date = line:match("^(%S+) (%d+)$")
    if tag then
      dates[tag] = tonumber(date)
    end
  end
  -- 元の Git.get_target と同じ規則で version 指定を決める
  local spec = (plugin.version == nil and plugin.branch == nil) and Config.options.defaults.version or plugin.version
  local versions = vim.tbl_filter(function(v)
    return (dates[v.tag] or math.huge) <= cutoff
  end, Git.get_versions(plugin.dir, spec))
  return Semver.last(versions)
end

local get_target = Git.get_target

---@param plugin LazyPlugin
function Git.get_target(plugin)
  local target = get_target(plugin)
  -- ローカルプラグインと commit / tag 固定のプラグインは対象外
  if not (target and target.commit) or plugin._.is_local or plugin.commit or plugin.tag then
    return target
  end
  local info = Git.info(plugin.dir)
  local cloned = plugin._.cloned
  if not info or (not cloned and Git.eq(info, target)) then
    return target
  end

  -- 条件を満たす更新先がなければ今のコミットに留める
  -- 新規 clone 直後は留める先がないので元の更新先を使う
  local fallback = cloned and target or { branch = target.branch, commit = info.commit }
  local cutoff = os.time() - MIN_AGE

  if target.version then
    local version = aged_version(plugin, cutoff)
    if not version then
      return fallback
    end
    local commit = Git.ref(plugin.dir, "tags/" .. version.tag)
    -- 今のコミットより古いタグへは戻さない
    if not cloned and git(plugin.dir, { "merge-base", "--is-ancestor", commit, "HEAD" }) then
      return fallback
    end
    return { branch = target.branch, version = version, tag = version.tag, commit = commit }
  end

  -- HEAD.. で絞り、今のコミットより古いコミットへは戻さない
  local commit = aged_commit(plugin.dir, cloned and target.commit or "HEAD.." .. target.commit, cutoff)
  return commit and { branch = target.branch, commit = commit } or fallback
end
