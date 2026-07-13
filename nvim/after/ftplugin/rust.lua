-- Rust の慣習に合わせてインデントをスペース4に設定
-- filetype ごとにインデントを変えたい場合は after/ftplugin/<filetype>.lua を追加する
-- リポジトリ・ファイル単位で上書きしたい場合は .editorconfig を置く（こちらが優先される）
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true
