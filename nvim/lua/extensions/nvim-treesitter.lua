require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'bash', 'comment', 'css', 'csv', 'dockerfile', 'go', 'graphql', 'html', 'javascript', 'jsdoc', 'json', 'lua', 'markdown', 'mermaid', 'prisma',
    'python', 'ruby', 'rust', 'sql', 'ssh_config', 'tsx', 'typescript', 'vim', 'vimdoc',
  },
  -- true だとパーサー未導入のファイルを開いた際に同期インストールで UI がブロックする
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    -- 1MB 超のファイルは初回パースが重すぎるためハイライトを無効化
    disable = function(_, bufnr)
      local name = vim.api.nvim_buf_get_name(bufnr)
      local stat = name ~= '' and vim.uv.fs_stat(name) or nil
      return stat ~= nil and stat.size > 1024 * 1024
    end,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
    -- treesitter indent は改行のたびにクエリが走り、巨大ファイルで入力が重くなる
    disable = function(_, bufnr)
      return require('bigfile').is_big(bufnr)
    end,
  },
}
