-- chunk の max_file_size は line_num モジュールには効かず、line_num は
-- CursorMoved ごとに searchpair を呼ぶため、超長行 (minified) ファイルで
-- 1回の呼び出しが数秒ブロックしフリーズする。get_chunk_range 自体を
-- bigfile バッファでは即 NO_CHUNK を返すようにガードする
local chunkHelper = require('hlchunk.utils.chunkHelper')
local scope = require('hlchunk.utils.scope')
local orig_get_chunk_range = chunkHelper.get_chunk_range
chunkHelper.get_chunk_range = function(opts)
  local bufnr = opts and opts.pos and opts.pos.bufnr or 0
  if require('bigfile').is_big(bufnr) then
    return chunkHelper.CHUNK_RANGE_RET.NO_CHUNK, scope(bufnr, -1, -1)
  end
  return orig_get_chunk_range(opts)
end

require('hlchunk').setup {
  chunk = {
    enable = true,
    -- 巨大ファイルではカーソル移動ごとの chunk 計算が重いため無効化（bigfile と同じ閾値）
    max_file_size = require('bigfile').size_limit,
    style = {
      { fg = '#806d9c' },
      { fg = '#c21f30' },
    },
  },
  indent = {
    enable = true,
    style = {
      { fg = '#3b4261' },
    },
  },
  line_num = {
    enable = true,
    style = '#806d9c',
  },
  blank = {
    enable = false,
  },
}
