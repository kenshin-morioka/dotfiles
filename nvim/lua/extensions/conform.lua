-- terraform / tofu は mise でプロジェクトごとに切り替わる (グローバル未設定で shim は常に存在する)。
-- そのため実行ファイルの有無では選べず、そのディレクトリで有効な方を mise which で判定する
local function terraform_formatter(bufnr)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  for _, name in ipairs({ 'terraform', 'tofu' }) do
    if vim.system({ 'mise', 'which', name }, { cwd = dir }):wait().code == 0 then
      return { name .. '_fmt' }
    end
  end
  return {}
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
  -- 既定の cwd は nvim の cwd。shim のバージョン解決をファイルのあるプロジェクトに合わせる
  formatters = {
    terraform_fmt = { cwd = function(_, ctx) return ctx.dirname end },
    tofu_fmt = { cwd = function(_, ctx) return ctx.dirname end },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
