require('dropbar').setup {
  bar = {
    enable = function(buf, win, _)
      local filetype = vim.bo[buf].filetype
      local excluded = {
        'neo-tree',
        'toggleterm',
        'terminal',
        'help',
        'qf',
      }
      for _, ft in ipairs(excluded) do
        if filetype == ft then
          return false
        end
      end
      return vim.fn.win_gettype(win) == ''
        and vim.wo[win].winbar == ''
        and vim.bo[buf].buftype == ''
    end,
  },
}

vim.keymap.set('n', '<leader>dp', function()
  require('dropbar.api').pick()
end, { desc = 'Dropbar pick' })
