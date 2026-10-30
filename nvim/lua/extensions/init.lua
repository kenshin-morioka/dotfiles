local plugins = {
  {
    'nvim-treesitter/nvim-treesitter',
    -- main(rewrite)ブランチを使用。master は凍結済みで Neovim 0.12 の
    -- treesitter API 変更(match[id] がノードリストを返す)に非対応。
    branch = 'main',
    -- main は lazy-load 非対応(README 参照)
    lazy = false,
    build = ':TSUpdate',
    config = function() require 'extensions.nvim-treesitter' end,
  },
  {
    'Mofiqul/vscode.nvim',
    -- カラースキームは起動時に即ロードする。priority は lazy = false のときだけ効く
    -- (event 指定だと無視され、起動直後に未スタイル状態が一瞬見える)
    lazy = false,
    priority = 1000,
    config = function() require 'extensions.vscode-theme' end,
  },
  {
    'nvim-lualine/lualine.nvim',
    event = { 'VimEnter' },
    config = function() require 'extensions.lualine' end,
  },
  {
    'kevinhwang91/nvim-hlslens',
    -- 検索 (/ ? * 等) の直前にロードする。nvim-scrollbar の search handler が
    -- require('hlslens') した場合も lazy.nvim 経由でロードされる
    event = { 'CmdlineEnter' },
    keys = { '*', '#', 'n', 'N' },
    config = function() require 'extensions.nvim-hlslens' end,
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre' },
    config = function() require 'extensions.gitsigns' end,
  },
  {
    'petertriho/nvim-scrollbar',
    -- 2026-11-16 に main が v2 (setup オプション・handlers 削除) に置き換わるため v1 に固定
    branch = 'v1',
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
      -- 未入力時に過去に選択したファイルを frecency 順で上位表示する
      -- 最新 main は select_drop 等 telescope master 前提のため 0.1.x 互換のコミットに固定
      {
        'prochri/telescope-all-recent.nvim',
        commit = 'e437f60ea468268e49ffdc0c9ed7c5ba384e63cf',
        dependencies = { 'kkharji/sqlite.lua' },
      },
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
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp',
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    config = function() require 'extensions.luasnip' end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'numToStr/Comment.nvim',
    event = { 'BufNewFile', 'BufReadPre' },
    opts = {
      ignore = '^$',
    },
  },
  -- nvim-spectre は結果を同期描画するため大量マッチ時に固まる。
  -- grug-far は結果をストリーミング描画するので大量マッチでもブロックしない。
  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    keys = {
      { '<leader>sr', function() require('grug-far').open() end, desc = 'Search and Replace (Project)' },
      { '<leader>sf', function() require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } }) end, desc = 'Search and Replace (File)' },
      { '<leader>sw', function() require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } }) end, desc = 'Search current word' },
    },
    opts = {
      engines = {
        ripgrep = {
          extraArgs = '--hidden',
        },
      },
    },
  },
  {
    'uga-rosa/ccc.nvim',
    event = { 'BufNewFile', 'BufReadPre' },
    opts = {
      highlighter = {
        auto_enable = true,
      },
    },
  },
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = function() require 'extensions.mason' end,
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
    },
  },
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
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'extensions.nvim-lint' end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      { '<leader>cf', function() require('conform').format({ async = true }) end, desc = 'Format buffer' },
    },
    config = function() require 'extensions.conform' end,
  },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Git Diff View' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File History' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Branch History' },
      { '<leader>gc', function() require('extensions.diffview').safe_close() end, desc = 'Close Diff View' },
    },
    config = function() require 'extensions.diffview' end,
  },
  {
    'akinsho/git-conflict.nvim',
    version = '*',
    event = { 'BufReadPre' },
    config = function() require 'extensions.git-conflict' end,
  },
  {
    'linrongbin16/gitlinker.nvim',
    cmd = 'GitLink',
    keys = {
      { '<leader>go', '<cmd>GitLink!<cr>', mode = { 'n', 'v' }, desc = 'Open GitHub link in browser' },
    },
    opts = {},
  },
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
  {
    'shellRaining/hlchunk.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'extensions.hlchunk' end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function() require 'extensions.treesitter-context' end,
  },
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-telescope/telescope-fzf-native.nvim' },
    config = function() require 'extensions.dropbar' end,
  },
  {
    'rainbowhxch/accelerated-jk.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'extensions.accelerated-jk' end,
  },
  {
    'kevinhwang91/nvim-ufo',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'kevinhwang91/promise-async' },
    config = function() require 'extensions.nvim-ufo' end,
  },
  {
    'bassamsdata/namu.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function() require 'extensions.namu' end,
  },
  {
    'kkoomen/vim-doge',
    build = ':call doge#install()',
    event = { 'BufReadPre', 'BufNewFile' },
    init = function() require 'extensions.vim-doge' end,
  },
  {
    -- tmux / WezTerm / nvim のペイン移動を Ctrl+hjkl で統一する (WezTerm 側は wezterm/keybinds.lua)
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    -- WezTerm 側の端では移動を止める (nvim 内で反対側へ回り込ませない)
    opts = function()
      return {
        mux = { backend = require 'extensions.smart-splits-wezterm' },
        move = { at_edge = 'stop' },
      }
    end,
    keys = {
      { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = 'Navigate Left (nvim/tmux/WezTerm)' },
      { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = 'Navigate Down (nvim/tmux/WezTerm)' },
      { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = 'Navigate Up (nvim/tmux/WezTerm)' },
      { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = 'Navigate Right (nvim/tmux/WezTerm)' },
    },
  },
}

local opts = {
  checker = {
    enabled = true,
  },
  performance = {
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
        -- matchparen / netrwPlugin は無効化しない
        -- (括弧ハイライトは常用、netrw は neo-tree v3.x で無効化不要)
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 起動時の不足プラグインのインストールにも効くよう setup より前に読み込む
require("extensions.lazy-min-age")
require("lazy").setup(plugins, opts)
