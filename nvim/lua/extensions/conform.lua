-- terraform / tofu は mise でプロジェクトごとに切り替わる (グローバル未設定で shim は常に存在する)。
-- そのため実行ファイルの有無では選べず、そのディレクトリで有効な方を mise which で判定する。
-- mise which が固まっても保存を止めないよう待機に上限を設け、超過時は整形しない。
-- 戻り値は (実行ファイルのパス | nil, タイムアウトしたか)
local TIMEOUT_CODE = 124

local function mise_which(name, dir)
  local res = vim.system({ 'mise', 'which', name }, { cwd = dir, text = true }):wait(500)
  if res.code ~= 0 then
    return nil, res.code == TIMEOUT_CODE
  end
  return vim.trim(res.stdout), false
end

local function terraform_formatter(bufnr)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  for _, name in ipairs({ 'terraform', 'tofu' }) do
    local path, timed_out = mise_which(name, dir)
    if path then
      return { name .. '_fmt' }
    end
    -- 優先する terraform が判定できないまま tofu に切り替えない
    if timed_out then
      return {}
    end
  end
  return {}
end

-- mise activate は nvim 起動元プロジェクトの bin を PATH 先頭に置くため、コマンド名のままだと
-- 別プロジェクトのファイルを開いても起動元の版が使われる。対象ディレクトリで解決した実行ファイルを指定する
local function mise_formatter(name)
  return {
    command = function(_, ctx)
      return mise_which(name, ctx.dirname) or name
    end,
    cwd = function(_, ctx)
      return ctx.dirname
    end,
  }
end

require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    -- shfmt は zsh 方言未対応のため zsh には割り当てない
    json = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    toml = { 'taplo' },
    -- rubocop はグローバル install せず project-local (bundler) 前提。
    -- PATH に無い場合は lsp_fallback により ruby-lsp 側のフォーマットが使われる
    ruby = { 'rubocop' },
    terraform = terraform_formatter,
    ['terraform-vars'] = terraform_formatter,
  },
  formatters = {
    terraform_fmt = mise_formatter('terraform'),
    tofu_fmt = mise_formatter('tofu'),
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
