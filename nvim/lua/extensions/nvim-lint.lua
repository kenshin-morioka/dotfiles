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

-- nvim-lint 標準の typos parser は end_col を item.type (常に "typo" = 4) の長さで求めるため、
-- 下線が誤字の長さと一致しない。誤字本体 (item.typo) の長さを使う parser に差し替える
lint.linters.typos.parser = function(output)
  local diagnostics = {}
  for json in output:gmatch('[^\n]+') do
    local item = vim.json.decode(json)
    if item ~= nil and item.line_num ~= nil then
      diagnostics[#diagnostics + 1] = {
        lnum = item.line_num - 1,
        end_lnum = item.line_num - 1,
        col = item.byte_offset,
        end_col = item.byte_offset + #item.typo,
        severity = vim.diagnostic.severity.WARN,
        source = '[typos] ' .. item.type,
        message = '`' .. item.typo .. '` should be `' .. table.concat(item.corrections, ' or ') .. '`',
      }
    end
  end
  return diagnostics
end

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
    lint.try_lint()
    -- typos はディスク上のファイルを検査するため、未保存の内容に対して古い診断を出さないよう InsertLeave では実行しない
    if ev.event ~= 'InsertLeave' then
      lint.try_lint('typos')
    end
  end,
})

vim.keymap.set('n', '<leader>ll', try_lint, { desc = 'Lint current file' })
