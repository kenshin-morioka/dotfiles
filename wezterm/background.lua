local M = {}

-- 背景画像のパスを設定
local background_image = "/Users/moriokakenshin/src/github.com/kenshin-morioka/dotfiles/wezterm/nerve.jpg"

return {
    {
        source = {
            Gradient = {
            colors = { "#143e4eff", "#001522" },
            orientation = {
                Linear = { angle = -30.0 },
            },
            },
        },
        opacity = 0.75,
        width = "100%",
        height = "100%",
    },
    {
        source = { File = background_image },
        opacity = 0.12,
        vertical_align = "Middle",
        horizontal_align = "Right",
        horizontal_offset = "200px",
        repeat_x = "NoRepeat",
        repeat_y = "NoRepeat",
        -- width = "1431px",
        -- height = "1900px"
    },
}
