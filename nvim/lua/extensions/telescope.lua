local telescope = require 'telescope'

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-h>'] = 'which_key',
        ['<esc>'] = require('telescope.actions').close,
        ['<C-[>'] = require('telescope.actions').close,
      },
      n = {
        ['<C-h>'] = 'which_key',
      }
    },
    winblend = 20,
    preview = {
      treesitter = false,
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
  },
}
telescope.load_extension 'fzf'

-- telescope.setup の後に呼ぶ必要がある
require('telescope-all-recent').setup {
  default = {
    disable = true, -- 未指定の picker では無効にする
  },
  pickers = {
    find_files = {
      disable = false,
      use_cwd = true, -- cwd ごとに履歴を分ける
      sorting = 'frecency',
    },
  },
}

local builtin = require 'telescope.builtin'

vim.keymap.set('n', '<leader>ff', function()
  builtin.find_files({ no_ignore = true, hidden = true })
end)
vim.keymap.set('n', '<leader>fg', builtin.live_grep)
