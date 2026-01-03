local lint = require('lint')

-- リンターの設定
lint.linters_by_ft = {
  lua = { 'selene' },
  sh = { 'shellcheck' },
  bash = { 'shellcheck' },
  zsh = { 'shellcheck' },
  json = { 'jsonlint' },
  markdown = { 'markdownlint' },
}

-- 自動実行の設定
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  callback = function()
    lint.try_lint()
  end,
})

-- 手動実行用のキーマップ
vim.keymap.set('n', '<leader>ll', function()
  lint.try_lint()
end, { desc = 'Lint current file' })
