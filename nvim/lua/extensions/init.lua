local plugins = {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufNewFile', 'BufReadPre' },
    build = ':TSUpdate',
    config = function() require 'extensions.nvim-treesitter' end,
  },
  {
    'rmehri01/onenord.nvim',
    event = { 'VimEnter' },
    priority = 1000,
    config = function() require 'extensions.onenord' end,
  },
  {
    'nvim-lualine/lualine.nvim',
    event = { 'VimEnter' },
    config = function() require 'extensions.lualine' end,
  },
  {
    'kevinhwang91/nvim-hlslens',
    event = { 'FilterWritePre' },
    config = function() require 'extensions.nvim-hlslens' end,
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre' },
    config = function() require 'extensions.gitsigns' end,
  },
  {
    'petertriho/nvim-scrollbar',
    event = { 'BufNewFile', 'BufReadPre' },
    config = function() require 'extensions.nvim-scrollbar' end,
  },
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      '<leader>ff', '<leader>fg'
    },
    branch = '0.1.x',
    config = function() require 'extensions.telescope' end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    lazy = false,
    keys = {
      { '<leader>b', '<cmd>Neotree toggle<cr>', desc = 'Toggle NeoTree' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function() require 'extensions.neo-tree' end,
  },
  -- Snippets
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp',
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    config = function() require 'extensions.luasnip' end,
  },
  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  -- Comment
  {
    'numToStr/Comment.nvim',
    event = { 'BufNewFile', 'BufReadPre' },
    opts = {
      ignore = '^$',  -- 空行を無視
    },
  },
  -- Search and Replace
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>sr', function() require('spectre').open() end, desc = 'Search and Replace (Project)' },
      { '<leader>sf', function() require('spectre').open_file_search() end, desc = 'Search and Replace (File)' },
      { '<leader>sw', function() require('spectre').open_visual({ select_word = true }) end, desc = 'Search current word' },
    },
    opts = {},
  },
  -- Color highlighter
  {
    'uga-rosa/ccc.nvim',
    event = { 'BufNewFile', 'BufReadPre' },
    opts = {
      highlighter = {
        auto_enable = true,
      },
    },
  },
  -- Mason (LSP installer)
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = function() require 'extensions.mason' end,
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
    },
  },
  -- LSP
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function() require 'extensions.lspconfig' end,
  },
  -- Completion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      'onsails/lspkind.nvim',
    },
    config = function() require 'extensions.nvim-cmp' end,
  },
  -- Linter
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'extensions.nvim-lint' end,
  },
  -- Formatter
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      { '<leader>cf', function() require('conform').format({ async = true }) end, desc = 'Format buffer' },
    },
    config = function() require 'extensions.conform' end,
  },
  -- Git Diff Viewer
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Git Diff View' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File History' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Branch History' },
      { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = 'Close Diff View' },
    },
    config = function() require 'extensions.diffview' end,
  },
  -- Git Conflict resolver
  {
    'akinsho/git-conflict.nvim',
    version = '*',
    event = { 'BufReadPre' },
    config = function() require 'extensions.git-conflict' end,
  },
  -- Markdown Preview
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = 'cd app && npm install',
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown Preview' },
    },
    init = function() require 'extensions.markdown-preview' end,
  },
  -- Terminal
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = {
      { '<C-\\>', '<cmd>ToggleTerm<cr>', desc = 'Toggle Terminal', mode = { 'n', 't' } },
    },
    config = function() require 'extensions.toggleterm' end,
  },
  -- Indent guide and chunk highlight
  {
    'shellRaining/hlchunk.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'extensions.hlchunk' end,
  },
  -- Treesitter context (sticky header)
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function() require 'extensions.treesitter-context' end,
  },
  -- Breadcrumb navigation
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-telescope/telescope-fzf-native.nvim' },
    config = function() require 'extensions.dropbar' end,
  },
  -- Accelerated j/k movement
  {
    'rainbowhxch/accelerated-jk.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'extensions.accelerated-jk' end,
  },
  -- Better folding
  {
    'kevinhwang91/nvim-ufo',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'kevinhwang91/promise-async' },
    config = function() require 'extensions.nvim-ufo' end,
  },
  -- Symbol navigation
  {
    'bassamsdata/namu.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'extensions.namu' end,
  },
  -- Documentation generator
  {
    'kkoomen/vim-doge',
    build = ':call doge#install()',
    event = { 'BufReadPre', 'BufNewFile' },
    init = function() require 'extensions.vim-doge' end,
  },
}

local opts = {
  checker = {
    enabled = true,
  },
  preformance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        "gzip",
        "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins, opts)
