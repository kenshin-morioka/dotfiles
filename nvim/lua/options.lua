-- global
-- 24ビットRGBカラー有効化
vim.opt.termguicolors = true
-- ファイル末尾に移動した際に4行分の余白設定
vim.opt.scrolloff = 4
-- 検索時に大文字小文字無視
vim.opt.ignorecase = true
-- 検索時に大文字が含まれていたらignorecaseを無効化
vim.opt.smartcase = true
-- 置換時に画面下部に検索結果を表示
vim.opt.inccommand = 'split'
-- クリップボードの有効化
vim.opt.clipboard = 'unnamedplus'
-- Shift+矢印で選択開始（VSCode風）
vim.opt.keymodel = 'startsel,stopsel'
vim.opt.selectmode = 'key'
-- modeline無効化（外部ファイルからの任意コマンド実行を防止）
vim.opt.modeline = false
-- マウス操作を完全に無効化
vim.opt.mouse = ''

-- window
-- 行番号表示
vim.opt.number = true
-- 相対行番号表示
-- vim.opt.relativenumber = true
-- カーソル行を強調
vim.opt.cursorline = true
-- 標識のためのスペースを最左列に設ける
vim.opt.signcolumn = 'yes:1'
-- テキストの折り返しを無効化
vim.opt.wrap = false
-- 非表示文字の可視化
vim.opt.list = true
vim.opt.listchars = { eol = '↵', tab = '▸ ' }
-- 指定したカラム列を強調
-- vim.opt.colorcolumn = '100'

-- filetype detection
vim.filetype.add({
  pattern = {
    ['.*git%-hooks/.*'] = 'sh',
    ['.*%.git/hooks/.*'] = 'sh',
  },
})

-- buffer
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = '*',
  group = vim.api.nvim_create_augroup('buffer_set_options', {}),
  callback = function()
    -- swapfile作成を有効化（クラッシュ時のデータ復旧用）
    vim.bo.swapfile = true
    -- tab幅
    vim.bo.tabstop = 2
    -- tabをスペースに変換
    vim.bo.expandtab = true
    -- オートインデントをtabstopの値に
    vim.bo.shiftwidth = 0
  end
})
