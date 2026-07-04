-- nvim-treesitter main(rewrite)ブランチ用の設定。
-- highlight / indent は Neovim 本体の機能を FileType autocmd で有効化する方式。
-- 旧 master の incremental_selection(gnn/grn/grc/grm)は main で廃止された。
local ts = require('nvim-treesitter')

local ensure_installed = {
  'bash', 'comment', 'css', 'csv', 'dockerfile', 'go', 'graphql', 'html', 'javascript', 'jsdoc', 'json', 'lua', 'markdown', 'mermaid', 'prisma',
  'python', 'ruby', 'rust', 'sql', 'ssh_config', 'tsx', 'typescript', 'vim', 'vimdoc',
}

-- インストール済みなら no-op。非同期実行なので起動はブロックしない
ts.install(ensure_installed)

--- バッファに highlight / indent を有効化する
---@param bufnr number
---@param lang string
local function attach(bufnr, lang)
  -- 1MB 超のファイルは初回パースが重すぎるためハイライトを無効化
  local name = vim.api.nvim_buf_get_name(bufnr)
  local stat = name ~= '' and vim.uv.fs_stat(name) or nil
  if stat ~= nil and stat.size > 1024 * 1024 then
    return
  end

  -- ハイライト非対応言語などで失敗しうるため pcall
  if not pcall(vim.treesitter.start, bufnr, lang) then
    return
  end

  -- treesitter indent は改行のたびにクエリが走り、巨大ファイルで入力が重くなる
  if not require('bigfile').is_big(bufnr) then
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('nvim_treesitter_attach', {}),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then
      return
    end

    if vim.tbl_contains(ts.get_installed(), lang) then
      attach(ev.buf, lang)
    elseif vim.tbl_contains(ts.get_available(), lang) then
      -- 旧 auto_install 相当: 未導入パーサーをインストールしてからアタッチ
      ts.install(lang):await(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then
          attach(ev.buf, lang)
        end
      end)
    end
  end,
})
