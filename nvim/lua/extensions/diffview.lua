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
