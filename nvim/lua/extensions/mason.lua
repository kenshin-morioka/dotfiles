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
    'lua_ls',           -- Lua
    'ruby_lsp',         -- Ruby/Rails
    'ts_ls',            -- TypeScript/JavaScript
    'html',             -- HTML
    'cssls',            -- CSS
    'jsonls',           -- JSON
    'yamlls',           -- YAML
    'bashls',           -- Bash
  },
  automatic_installation = true,
}
