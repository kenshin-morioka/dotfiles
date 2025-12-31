require('luasnip.loaders.from_vscode').lazy_load {
  paths = {
    vim.fn.stdpath('data') .. '/lazy/friendly-snippets',
    vim.fn.stdpath('config') .. '/snippets',
  },
}
