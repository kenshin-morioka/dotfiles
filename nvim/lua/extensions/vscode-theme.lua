require('vscode').setup({
  transparent = true,
  italic_comments = false,
  underline_links = true,
  disable_nvimtree_bg = true,

  group_overrides = {
    -- keywords を bold に（onenord の styles.keywords = 'bold' 相当）
    ['@keyword'] = { bold = true },
    ['@keyword.function'] = { bold = true },
    ['@keyword.return'] = { bold = true },
    ['@keyword.operator'] = { bold = true },
    ['@conditional'] = { bold = true },
    ['@repeat'] = { bold = true },
    ['@include'] = { bold = true },
    ['@exception'] = { bold = true },
    Keyword = { bold = true },
    Conditional = { bold = true },
    Repeat = { bold = true },
    Statement = { bold = true },

    -- functions を bold に（onenord の styles.functions = 'bold' 相当）
    ['@function'] = { bold = true },
    ['@function.call'] = { bold = true },
    ['@function.builtin'] = { bold = true },
    ['@method'] = { bold = true },
    ['@method.call'] = { bold = true },
    Function = { bold = true },

    -- エディタのカーソル行背景を控えめに
    CursorLine = { bg = '#1e1e2e' },

    -- visual/select モードの選択範囲を薄い黄色に
    Visual = { bg = '#3a3520' },

    -- neo-tree のカーソル行からインデントマーカーへの背景色漏れを防止
    NeoTreeCursorLine = { bg = 'NONE', bold = true, underline = true },

    -- 既存の custom_highlights を維持
    MatchParen = { fg = 'NONE', bg = 'NONE', bold = true, underline = true },
    GitSignsAddLnInline = { fg = 'NONE', bg = 'NONE', underline = true },
    GitSignsChangeLnInline = { fg = 'NONE', bg = 'NONE', underline = true },
    GitSignsDeleteLnInline = { fg = 'NONE', bg = 'NONE', bold = true, underline = true },
  },
})

vim.cmd.colorscheme('vscode')
