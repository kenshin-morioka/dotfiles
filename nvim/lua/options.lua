-- global
vim.opt.termguicolors = true
vim.opt.scrolloff = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- 置換時に画面下部に検索結果を表示
vim.opt.inccommand = 'split'
vim.opt.clipboard = 'unnamedplus'
-- Shift+矢印で選択開始（VSCode風）
vim.opt.keymodel = 'startsel,stopsel'
vim.opt.selectmode = 'key'
-- modeline無効化（外部ファイルからの任意コマンド実行を防止）
vim.opt.modeline = false
vim.opt.mouse = ''

-- window
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes:1'
vim.opt.wrap = false
vim.opt.list = true
vim.opt.listchars = { eol = '↵', tab = '▸ ' }

-- filetype detection
vim.filetype.add({
  pattern = {
    ['.*git%-hooks/.*'] = 'sh',
    ['.*%.git/hooks/.*'] = 'sh',
  },
})

-- buffer
vim.opt.swapfile = true

-- インデントのデフォルト値（BufEnter で強制すると ftplugin や editorconfig を
-- 上書きしてしまうため、デフォルト値として設定するだけに留める）
-- 優先順位: デフォルト値 < after/ftplugin/<filetype>.lua < .editorconfig
vim.opt.tabstop = 2
vim.opt.expandtab = true
-- オートインデントをtabstopの値に
vim.opt.shiftwidth = 0
