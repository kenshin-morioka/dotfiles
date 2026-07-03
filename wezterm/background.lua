local M = {}

function M.create(opacity)
	return {
		{
			source = {
				Gradient = {
					-- colors = { "#143e4eff", "#010b12" },
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

M.default = M.create(0.85)

return M
