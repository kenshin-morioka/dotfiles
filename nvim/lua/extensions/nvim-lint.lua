local lint = require('lint')

-- ~/.config/nvim は dotfiles/nvim へのシンボリックリンクなので、realpath で実体に解決してから
-- 親ディレクトリ (dotfiles ルート) の .markdownlint.json を参照する
local config_dir = vim.uv.fs_realpath(vim.fn.stdpath('config')) or vim.fn.stdpath('config')
lint.linters.markdownlint.args = {
  '--config',
  vim.fs.joinpath(vim.fs.dirname(config_dir), '.markdownlint.json'),
  '--stdin',
}

lint.linters_by_ft = {
  lua = { 'selene' },
  sh = { 'shellcheck' },
  bash = { 'shellcheck' },
  -- shellcheck は zsh 非対応 (SC1071) のため zsh 本体の構文チェック (zsh -n) を使う
  zsh = { 'zsh' },
  json = { 'jsonlint' },
  markdown = { 'markdownlint' },
}

-- linters_by_ft['*'] は nvim-lint が解釈しないため、全ファイル共通の typos は明示的に実行する
local function try_lint()
  lint.try_lint()
  lint.try_lint('typos')
end

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  callback = function(ev)
    -- 巨大ファイルでは InsertLeave のたびに全文を linter に流すと重いためスキップ
    -- （手動実行の <leader>ll は使用可能）
    if require('bigfile').is_big(ev.buf) then
      return
    end
    try_lint()
  end,
})

vim.keymap.set('n', '<leader>ll', try_lint, { desc = 'Lint current file' })
