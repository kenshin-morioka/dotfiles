local cmp = require 'cmp'
local act = require 'extensions.nvim-cmp-actions'
local luasnip = require 'luasnip'

local map = cmp.mapping

-- 巨大ファイルでは buffer ソースの単語インデックス化が重いため対象から外す
local function indexable_bufs()
  local bufnr = vim.api.nvim_get_current_buf()
  if require('bigfile').is_big(bufnr) then
    return {}
  end
  return { bufnr }
end

cmp.setup {
  mapping = map.preset.insert {
    ['<C-d>'] = map.scroll_docs(-4),
    ['<C-f>'] = map.scroll_docs(4),
    ['<C-Space>'] = map.complete(),
    ['<C-e>'] = map.abort(),
    ['<CR>'] = map.confirm { select = false },
    ['<Tab>'] = map(act.tab, { 'i' }),
    ['<S-Tab>'] = map(act.shift_tab, { 'i' }),
  },
  sources = cmp.config.sources {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer', option = { get_bufnrs = indexable_bufs } },
    { name = 'path' },
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  formatting = {
    format = require('lspkind').cmp_format {
      mode = 'symbol',
      preset = 'codicons',
    },
  },
}

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources {
    { name = 'cmdline' },
    { name = 'path' },
  },
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources {
    {
      name = 'buffer',
      option = {
        keyword_pattern = [[\k\+]],
        get_bufnrs = indexable_bufs,
      },
    },
  },
})
