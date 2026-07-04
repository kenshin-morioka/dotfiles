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
