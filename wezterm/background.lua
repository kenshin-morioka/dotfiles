local M = {}

function M.create(opacity)
	return {
		{
			source = {
				Gradient = {
					colors = { "#2D353B", "#050505" },
					orientation = {
						Linear = { angle = -30.0 },
					},
				},
			},
			opacity = opacity,
			width = "100%",
			height = "100%",
		},
	}
end

-- 起動時の既定 opacity。wezterm.lua の透過トグルもこの値を基準にする
M.default_opacity = 0.85
M.default = M.create(M.default_opacity)

return M
