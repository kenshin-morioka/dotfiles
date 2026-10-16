require('mason').setup {
  ui = {
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  },
}

require('mason-lspconfig').setup {
  ensure_installed = {
    'lua_ls',
    'ruby_lsp',
    'ts_ls',
    'html',
    'cssls',
    'jsonls',
    'yamlls',
    'bashls',
    'rust_analyzer',
  },
}
