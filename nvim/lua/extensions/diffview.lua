local M = {}

-- DiffviewClose 時に neo-tree の close_if_last_window で vim が終了する問題の対策
-- eventignore で BufEnter/WinEnter を一時的に抑制し、neo-tree の自動クローズを防ぐ
function M.safe_close()
  local saved_eventignore = vim.o.eventignore
  vim.o.eventignore = 'all'

  vim.cmd('DiffviewClose')

  local wins = vim.api.nvim_list_wins()
  local has_normal_win = false
  for _, w in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(w)
    local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
    local is_floating = vim.api.nvim_win_get_config(w).relative ~= ''
    if ft ~= 'neo-tree' and not is_floating then
      has_normal_win = true
      break
    end
  end

  if not has_normal_win then
    vim.cmd('botright vnew')
  end

  vim.o.eventignore = saved_eventignore
end

require('diffview').setup {
  enhanced_diff_hl = true,
  view = {
    merge_tool = {
      layout = 'diff3_mixed',
    },
  },
}

-- diffview.nvim の仮想バッファに対してスワップファイルを無効化
-- diffview:// プロトコルのバッファはファイルシステム上に実体がないため、
-- スワップファイルは不要であり、E325エラーの原因となる
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = 'diffview://*',
  group = vim.api.nvim_create_augroup('diffview_noswap', {}),
  callback = function()
    vim.opt_local.swapfile = false
  end,
})

return M
