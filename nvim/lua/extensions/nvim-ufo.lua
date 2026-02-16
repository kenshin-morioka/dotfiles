vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require('ufo').setup {
  provider_selector = function(bufnr, filetype, buftype)
    -- 特殊バッファタイプはフォールディング不要
    if buftype == 'nofile' or buftype == 'nowrite' or buftype == 'acwrite' then
      return ''
    end

    -- diffview:// プロトコルのバッファを除外
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match('^diffview://') then
      return ''
    end

    -- diff モードが有効なウィンドウのバッファを除外
    local winid = vim.fn.bufwinid(bufnr)
    if winid ~= -1 and vim.api.nvim_get_option_value('diff', { win = winid }) then
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

-- diff バッファで nvim-ufo の "index out of bounds" エラーを防止する autocmd群
-- unstaged な差分では右パネルが実ファイルバッファ(buftype="")のため、
-- ufo がアタッチされたまま diff モードに入り、Buffer._lines と実際の行数が乖離する
local ufo_diff_group = vim.api.nvim_create_augroup('ufo_diff_guard', {})

-- BufWinEnter/WinEnter: diff ウィンドウに入った時点で ufo を即座に detach
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
  group = ufo_diff_group,
  callback = function()
    if vim.wo.diff then
      pcall(require('ufo').detach, vim.api.nvim_get_current_buf())
    end
  end,
})

-- OptionSet: diff モードの ON/OFF 切り替え時に detach/attach
vim.api.nvim_create_autocmd('OptionSet', {
  pattern = 'diff',
  group = ufo_diff_group,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.wo.diff then
      pcall(require('ufo').detach, bufnr)
    else
      -- diff モードから出た: 通常バッファなら ufo を再アタッチ
      local bt = vim.bo[bufnr].buftype
      if bt ~= 'nofile' and bt ~= 'nowrite' and bt ~= 'acwrite'
        and bt ~= 'terminal' and bt ~= 'prompt' then
        pcall(require('ufo').attach, bufnr)
      end
    end
  end,
})

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
