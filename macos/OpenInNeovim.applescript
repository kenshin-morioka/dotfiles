-- Finder からダブルクリック (もしくはドラッグ&ドロップ) で渡されたファイルを
-- WezTerm の新規ウィンドウで Neovim を起動して開くランチャー .app のソース。
--
-- ビルド方法: dotfiles ルートで `make macos-app`
-- 設定方法: Finder で対象ファイルを右クリック → 情報を見る →
--           「このアプリケーションで開く」を OpenInNeovim にして「すべてを変更」

property weztermBin : "/Applications/WezTerm.app/Contents/MacOS/wezterm"
property nvimBin : "/opt/homebrew/bin/nvim"

-- AppleScript の `do shell script` は最小 PATH で実行されるため、
-- login shell 経由で wezterm を起動して `.zprofile` の PATH を継承させる。
-- (markdownlint など Homebrew/mise 経由のツールを nvim から呼ぶ際に必要)
on launchNeovim(cwdPath, fileArgs)
	set inner to quoted form of weztermBin & " start --always-new-process --cwd " & quoted form of cwdPath & " -- " & quoted form of nvimBin & fileArgs
	do shell script "/bin/zsh -lc " & quoted form of inner
end launchNeovim

-- 各ファイルを「親ディレクトリを cwd にした別ウィンドウ」で開く。
-- NeoTree がファイルのある階層からツリー展開されるようにするため。
on open theFiles
	repeat with aFile in theFiles
		set filePath to POSIX path of aFile
		set parentDir to do shell script "/usr/bin/dirname " & quoted form of filePath
		launchNeovim(parentDir, " " & quoted form of filePath)
	end repeat
end open

on run
	launchNeovim(POSIX path of (path to home folder), "")
end run
