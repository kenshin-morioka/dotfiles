require('luasnip.loaders.from_vscode').lazy_load {
  paths = { vim.fn.stdpath('data') .. '/lazy/friendly-snippets' },
  -- friendly-snippets の terraform はインデントが 3 スペースで毎回直す必要があるため使わず、snippets/terraform.json で定義する
  exclude = { 'terraform' },
}
require('luasnip.loaders.from_vscode').lazy_load {
  paths = { vim.fn.stdpath('config') .. '/snippets' },
}
