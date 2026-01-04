require('treesitter-context').setup {
  enable = true,
  max_lines = 3,
  min_window_height = 0,
  line_numbers = true,
  multiline_threshold = 20,
  trim_scope = 'outer',
  mode = 'cursor',
  separator = nil,
  zindex = 20,
}

vim.keymap.set('n', '<leader>tc', function()
  require('treesitter-context').go_to_context(vim.v.count1)
end, { desc = 'Go to context' })
