vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require('ufo').setup {
  provider_selector = function(bufnr, filetype, buftype)
    -- 特殊バッファタイプはフォールディング不要（diffview:// 等の仮想バッファでの
    -- "index out of bounds" エラーを防止）
    if buftype == 'nofile' or buftype == 'nowrite' or buftype == 'acwrite' then
      return ''
    end
    local excluded = {
      'neo-tree',
      'toggleterm',
      'terminal',
      'help',
      'qf',
      'DiffviewFiles',
      'DiffviewFileHistory',
    }
    for _, ft in ipairs(excluded) do
      if filetype == ft then
        return ''
      end
    end
    return { 'treesitter', 'indent' }
  end
}

vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'Open folds except kinds' })
vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = 'Close folds with' })
vim.keymap.set('n', 'K', function()
  local winid = require('ufo').peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end, { desc = 'Peek fold or hover' })
