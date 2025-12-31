return {
  -- neo-tree.nvimプラグインの定義
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",  -- v3.xブランチを使用
  -- 必要な依存プラグインを指定
  dependencies = {
    "nvim-lua/plenary.nvim",     -- Luaユーティリティ関数群
    "nvim-tree/nvim-web-devicons", -- ファイルアイコン表示用
    "MunifTanjim/nui.nvim",      -- UIコンポーネントライブラリ
  },
  config = function()
    -- カレントディレクトリでLazyGitを開くカスタムコマンドを定義
    -- :LazyGitCurrent で呼び出し可能
    vim.api.nvim_create_user_command("LazyGitCurrent", function()
      local path = vim.fn.expand('%:p:h')  -- 現在のファイルの絶対パスを取得
      vim.cmd('tabnew | terminal lazygit -p ' .. path)  -- 新しいタブでLazyGitを開く
      vim.cmd('startinsert')  -- ターミナルモードを開始
    end, {})

    -- グローバルなCtrl+Tのマッピングを設定
    -- ディレクトリを新しいタブで開く機能
    vim.api.nvim_set_keymap('n', '<C-t>', 
      ':lua require("neo-tree.command").execute({ action = "open_directory_in_new_tab" })<CR>', 
      { noremap = true, silent = true })

    -- neo-treeの主要設定
    require("neo-tree").setup({
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      -- neo-treeウィンドウ内でのキーマッピング
      window = {
        mappings = {
          ["<C-g>"] = "open_lazygit",   -- Ctrl+G: LazyGitを開く
          ["<C-t>"] = "open_in_wezterm", -- Ctrl+T: WezTermで開く
          ["<C-h>"] = "toggle_hidden",   -- Ctrl+H: 隠しファイルの表示切替
        },
      },
      -- カスタムコマンドの定義
      commands = {
        -- 選択中のパスでLazyGitを開く
        open_lazygit = function(state)
          local node = state.tree:get_node()  -- 選択中のノード取得
          local path = node:get_id()          -- ノードのパス取得
          vim.cmd('tabnew | terminal lazygit -p ' .. path)  -- 新タブでLazyGit起動
          vim.cmd('startinsert')
        end,

        -- 選択中のパスで新しいWezTermタブを開く
        open_in_wezterm = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          -- ファイルが選択されている場合は親ディレクトリを使用
          if node.type ~= "directory" then
            path = vim.fn.fnamemodify(path, ":h")
          end
          -- WeztTermコマンドを構築して実行
          local cmd = "wezterm cli spawn --cwd " .. vim.fn.shellescape(path)
          os.execute(cmd)
          -- 操作完了を通知
          vim.notify("WezTerm: 新しいタブを開きました - パス: " .. path, vim.log.levels.INFO)
        end,

        -- 隠しファイルの表示/非表示を切り替え
        toggle_hidden = function(state)
          -- ファイルシステムの現在の状態を取得
          local fs_state = require("neo-tree.sources.filesystem").get_state()
          -- 表示状態を反転
          fs_state.filtered_items.visible = not fs_state.filtered_items.visible
          fs_state.filtered_items.hide_dotfiles = not fs_state.filtered_items.hide_dotfiles
          fs_state.filtered_items.hide_gitignored = not fs_state.filtered_items.hide_gitignored
          -- ツリーを更新
          require("neo-tree.sources.filesystem").refresh(state)
          -- 現在の状態を通知
          local visibility = fs_state.filtered_items.visible and "表示" or "非表示"
          vim.notify("隠しファイルを" .. visibility .. "に設定しました", vim.log.levels.INFO)
        end,
      },
    })
  end,
}
