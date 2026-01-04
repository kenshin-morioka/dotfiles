-- Normal to Command
vim.keymap.set("n", ":", ";")
vim.keymap.set("n", ";", ":")

-- automatically joump to end of text you pasted
vim.keymap.set("v", "y", "y`]")
vim.keymap.set({ "v", "n" }, "p", "p`]")

vim.keymap.set("n", "ZZ", "<NOP>")
vim.keymap.set("n", "ZQ", "<NOP>")

-- do not overwrite default register
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "X", '"_X')

-- leader
vim.api.nvim_set_var("mapleader", ",")
vim.api.nvim_set_var("maplocalleader", "\\")

-- buffer
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")
vim.keymap.set("n", "<leader>q", ":bp|bd #<CR>")

-- cursor movement (Option + Arrow)
vim.keymap.set("i", "<M-Left>", "<C-o>b") -- 前の単語へ
vim.keymap.set("i", "<M-Right>", "<C-o>w") -- 次の単語へ
vim.keymap.set("i", "<M-BS>", "<C-w>") -- 前の単語を削除
vim.keymap.set("n", "<M-Left>", "b") -- 前の単語へ
vim.keymap.set("n", "<M-Right>", "w") -- 次の単語へ
vim.keymap.set("n", "<M-Up>", "<C-u>") -- 半ページ上へ
vim.keymap.set("n", "<M-Down>", "<C-d>") -- 半ページ下へ
vim.keymap.set("i", "<M-Up>", "<C-o><C-u>") -- 半ページ上へ
vim.keymap.set("i", "<M-Down>", "<C-o><C-d>") -- 半ページ下へ

-- 単語単位で選択 (Shift + Option + Arrow)
vim.keymap.set("i", "<S-M-Left>", "<C-o>vb") -- インサート：選択開始して前の単語へ
vim.keymap.set("i", "<S-M-Right>", "<C-o>vw") -- インサート：選択開始して次の単語へ
vim.keymap.set("n", "<S-M-Left>", "vb") -- ノーマル：選択開始して前の単語へ
vim.keymap.set("n", "<S-M-Right>", "vw") -- ノーマル：選択開始して次の単語へ
vim.keymap.set({ "v", "s" }, "<S-M-Left>", "b") -- 選択範囲を前の単語へ拡張
vim.keymap.set({ "v", "s" }, "<S-M-Right>", "w") -- 選択範囲を次の単語へ拡張

-- Terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>") -- Escでノーマルモードへ
vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h") -- 左ウィンドウへ移動
vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j") -- 下ウィンドウへ移動
vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k") -- 上ウィンドウへ移動
vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l") -- 右ウィンドウへ移動

-- Comment (Select mode)
vim.keymap.set("s", "gc", "<C-g>gc", { remap = true }) -- セレクトモードでコメントトグル
vim.keymap.set("s", "gb", "<C-g>gb", { remap = true }) -- セレクトモードでブロックコメントトグル

-- Diagnostics
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float) -- diagnosticsをフロート表示
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist) -- diagnosticsをリスト表示

-- Clear search highlight
vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR>", { silent = true })
