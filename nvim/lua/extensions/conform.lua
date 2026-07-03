require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    zsh = { 'shfmt' },
    json = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    toml = { 'taplo' },
    -- rubocop はグローバル install せず project-local (bundler) 前提。
    -- PATH に無い場合は lsp_fallback により ruby-lsp 側のフォーマットが使われる
    ruby = { 'rubocop' },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
