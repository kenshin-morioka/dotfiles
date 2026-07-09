-- 巨大ファイルを検知して重い機能を自動的に無効化するためのモジュール
-- 各プラグイン設定から require('bigfile').is_big(bufnr) で参照する
local M = {}

-- このサイズまたは行数を超えたら「巨大ファイル」とみなす
M.size_limit = 256 * 1024 -- 256KB
M.line_limit = 3000
-- 1行がこれを超えたら minified ファイルとみなす
-- 超長行は treesitter のキャプチャ処理が1行に集中し描画がフリーズする
M.long_line_limit = 5000

--- バッファに long_line_limit を超える行があるか (minified ファイル検知)
--- 結果は b:bigfile_long_line にキャッシュする
---@param bufnr number|nil 省略または0でカレントバッファ
---@return boolean
function M.has_long_line(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local cached = vim.b[bufnr].bigfile_long_line
  if cached ~= nil then
    return cached
  end
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return false
  end

  local long = false
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if #line > M.long_line_limit then
      long = true
      break
    end
  end
  vim.b[bufnr].bigfile_long_line = long
  return long
end

--- バッファが巨大ファイルかどうかを判定する
--- 読み込み済みバッファでは結果を b:bigfile にキャッシュする
---@param bufnr number|nil 省略または0でカレントバッファ
---@return boolean
function M.is_big(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local cached = vim.b[bufnr].bigfile
  if cached ~= nil then
    return cached
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  local stat = name ~= '' and vim.uv.fs_stat(name) or nil
  local big = (stat ~= nil and stat.size > M.size_limit)
    or (vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_line_count(bufnr) > M.line_limit)
    or M.has_long_line(bufnr)

  -- 読み込み前のバッファは行数が確定していないためキャッシュしない
  if vim.api.nvim_buf_is_loaded(bufnr) then
    vim.b[bufnr].bigfile = big
  end
  return big
end

-- 読み込み完了時に判定をキャッシュし、巨大ファイルなら通知する
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('bigfile_detect', {}),
  callback = function(ev)
    if M.is_big(ev.buf) then
      vim.notify(
        ('bigfile: %s は巨大ファイルのため一部の重い機能を無効化しました'):format(
          vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ':t')
        ),
        vim.log.levels.INFO
      )
    end
  end,
})

return M
