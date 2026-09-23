local lint = require('lint')

-- markdownlint の設定ファイルを指定
-- ~/.config/nvim は dotfiles/nvim へのシンボリックリンクなので、realpath で実体に解決してから
-- 親ディレクトリ (dotfiles ルート) の .markdownlint.json を参照する
local config_dir = vim.uv.fs_realpath(vim.fn.stdpath('config')) or vim.fn.stdpath('config')
lint.linters.markdownlint.args = {
  '--config',
  vim.fs.joinpath(vim.fs.dirname(config_dir), '.markdownlint.json'),
  '--stdin',
}

-- リンターの設定
lint.linters_by_ft = {
  lua = { 'selene' },
  sh = { 'shellcheck' },
  bash = { 'shellcheck' },
  zsh = { 'shellcheck' },
  json = { 'jsonlint' },
  markdown = { 'markdownlint' },
  ['*'] = { 'typos' },
}

-- 自動実行の設定
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  callback = function(ev)
    -- 巨大ファイルでは InsertLeave のたびに全文を linter に流すと重いためスキップ
    -- （手動実行の <leader>ll は使用可能）
    if require('bigfile').is_big(ev.buf) then
      return
    end
    lint.try_lint()
  end,
})

-- 手動実行用のキーマップ
vim.keymap.set('n', '<leader>ll', function()
  lint.try_lint()
end, { desc = 'Lint current file' })
