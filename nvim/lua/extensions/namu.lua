require('namu').setup {
  namu_symbols = {
    enable = true,
    options = {
      AllowKinds = {
        default = {
          "Function", "Method", "Class", "Module", "Property", "Variable",
        },
      },
    },
  },
  ui_select = { enable = false },
  colorscheme = { enable = false },
}

-- LSPがある場合のみシンボル表示
vim.keymap.set('n', '<leader>ss', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    vim.cmd('Namu symbols')
  else
    vim.notify('LSP not available for this buffer', vim.log.levels.WARN)
  end
end, { desc = 'Namu symbols', silent = true })
