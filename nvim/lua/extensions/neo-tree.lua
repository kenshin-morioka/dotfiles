vim.api.nvim_create_user_command("LazyGitCurrent", function()
  local path = vim.fn.expand('%:p:h')
  vim.cmd('tabnew | terminal lazygit -p ' .. path)
  vim.cmd('startinsert')
end, {})

vim.api.nvim_set_keymap('n', '<C-t>',
  ':lua require("neo-tree.command").execute({ action = "open_directory_in_new_tab" })<CR>',
  { noremap = true, silent = true })

require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    follow_current_file = {
      enabled = true,
      leave_dirs_open = true,
    },
    use_libuv_file_watcher = true,
  },
  window = {
    mappings = {
      ["<cr>"] = "open",
      ["<2-LeftMouse>"] = "open",
      ["P"] = { "toggle_preview", config = { use_float = false, use_image_nvim = false } },
      ["<C-g>"] = "open_lazygit",
      ["<C-t>"] = "open_in_wezterm",
      ["<C-h>"] = "toggle_hidden",
    },
  },
  commands = {
    open_lazygit = function(state)
      local node = state.tree:get_node()
      local path = node:get_id()
      vim.cmd('tabnew | terminal lazygit -p ' .. path)
      vim.cmd('startinsert')
    end,
    open_in_wezterm = function(state)
      local node = state.tree:get_node()
      local path = node:get_id()
      if node.type ~= "directory" then
        path = vim.fn.fnamemodify(path, ":h")
      end
      local cmd = "wezterm cli spawn --cwd " .. vim.fn.shellescape(path)
      os.execute(cmd)
      vim.notify("WezTerm: 新しいタブを開きました - パス: " .. path, vim.log.levels.INFO)
    end,
    toggle_hidden = function(state)
      local fs_state = require("neo-tree.sources.filesystem").get_state()
      fs_state.filtered_items.visible = not fs_state.filtered_items.visible
      fs_state.filtered_items.hide_dotfiles = not fs_state.filtered_items.hide_dotfiles
      fs_state.filtered_items.hide_gitignored = not fs_state.filtered_items.hide_gitignored
      require("neo-tree.sources.filesystem").refresh(state)
      local visibility = fs_state.filtered_items.visible and "表示" or "非表示"
      vim.notify("隠しファイルを" .. visibility .. "に設定しました", vim.log.levels.INFO)
    end,
  },
})

vim.cmd('Neotree show')

-- :q で neo-tree だけが残る問題を解決
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local tree_wins = {}
    local floating_wins = {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match("neo%-tree") ~= nil then
        table.insert(tree_wins, w)
      end
      if vim.api.nvim_win_get_config(w).relative ~= '' then
        table.insert(floating_wins, w)
      end
    end
    if 1 == #wins - #floating_wins - #tree_wins then
      for _, w in ipairs(tree_wins) do
        vim.api.nvim_win_close(w, true)
      end
    end
  end
})

-- FocusGainedでgit状態を更新（neo-treeが表示されている場合のみ）
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  pattern = "*",
  callback = function()
    -- neo-treeウィンドウが表示されているかチェック
    local neo_tree_open = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_buf_get_option(buf, "filetype")
      if ft == "neo-tree" then
        neo_tree_open = true
        break
      end
    end

    -- neo-treeが開いている場合のみrefresh
    if neo_tree_open then
      local state = require("neo-tree.sources.manager").get_state("filesystem")
      if state then
        require("neo-tree.sources.filesystem.commands").refresh(state)
      end
    end
  end,
})
