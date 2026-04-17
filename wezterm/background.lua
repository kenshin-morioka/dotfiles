local M = {}

-- 背景画像のパスを環境変数HOMEを使用して設定
local home = os.getenv("HOME")
local background_image = home .. "/src/github.com/kenshin-morioka/dotfiles/wezterm/nerve.jpg"

function M.create(opacity)
	return {
		{
			source = {
				Gradient = {
					colors = { "#143e4eff", "#010b12" },
					orientation = {
						Linear = { angle = -30.0 },
					},
				},
			},
			opacity = opacity,
			width = "100%",
			height = "100%",
		},
		-- {
		-- 	source = { File = background_image },
		-- 	opacity = 0.12,
		-- 	vertical_align = "Middle",
		-- 	horizontal_align = "Right",
		-- 	horizontal_offset = "200px",
		-- 	repeat_x = "NoRepeat",
		-- 	repeat_y = "NoRepeat",
		-- 	-- width = "1431px",
		-- 	-- height = "1900px"
		-- },
	}
end

M.default = M.create(0.80)

return M
