-- Diagnostic settings
-- NOTE: vim.diagnostic.config はここ 1 箇所に統合する。
-- 他所（appearance.lua 等）で呼ぶと signs キーごと上書きされアイコンが消える。
vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '󰌶',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = true,
  },
})

-- LSP capabilities for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Keymaps on LSP attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    -- Navigation
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)

    -- Info
    vim.keymap.set('n', '<leader>k', vim.lsp.buf.signature_help, opts)

    -- Actions
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)

    -- Diagnostics
    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
  end,
})

-- LSP server configurations
-- capabilities は全サーバー共通で付与するため、ここには個別設定のみ書く
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = {
          library = vim.api.nvim_get_runtime_file('', true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },
  ruby_lsp = {
    root_markers = { '.git', 'Gemfile' },
    init_options = {
      formatter = 'auto',
      linters = { 'rubocop' },
    },
  },
  ts_ls = {},
  rust_analyzer = {},
  html = {},
  cssls = {},
  jsonls = {},
  yamlls = {},
  bashls = {},
}

for name, config in pairs(servers) do
  vim.lsp.config(name, vim.tbl_extend('force', { capabilities = capabilities }, config))
end

-- Enable LSP servers
vim.lsp.enable(vim.tbl_keys(servers))
