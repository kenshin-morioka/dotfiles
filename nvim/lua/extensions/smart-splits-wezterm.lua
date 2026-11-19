-- smart-splits.nvim 用の WezTerm バックエンド (v3 は WezTerm 連携を同梱しないため自前で持つ)。
-- nvim の端に着いたとき、WezTerm の隣のペインへフォーカスを移す。

local DIRECTIONS = { left = 'Left', right = 'Right', up = 'Up', down = 'Down' }

-- wezterm cli が応答しないと nvim の UI が固まるため打ち切り、失敗として扱う。
local TIMEOUT_MS = 1000

local function wezterm_cli(...)
  local result = vim.system({ 'wezterm', 'cli', ... }, { text = true }):wait(TIMEOUT_MS)
  -- kill 後もパイプが閉じないと nil が返る
  if not result then
    return false, ''
  end
  return result.code == 0, vim.trim(result.stdout or '')
end

return {
  name = 'wezterm',
  protocol_version = '3.0.0',
  detect = function()
    return vim.env.WEZTERM_PANE ~= nil and vim.fn.executable('wezterm') == 1
  end,
  move = function(direction)
    local ok, pane_id = wezterm_cli('get-pane-direction', DIRECTIONS[direction])
    if not ok or pane_id == '' then
      return false
    end
    return wezterm_cli('activate-pane-direction', DIRECTIONS[direction])
  end,
}
