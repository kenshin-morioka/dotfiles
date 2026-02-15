local M = {}

-- 背景画像のパスを環境変数HOMEを使用して設定
local home = os.getenv("HOME")
local background_image = home .. "/src/github.com/kenshin-morioka/dotfiles/wezterm/nerve.jpg"

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
        opacity = 1,
        width = "100%",
        height = "100%",
    },
    -- {
    --     source = { File = background_image },
    --     opacity = 0.12,
    --     vertical_align = "Middle",
    --     horizontal_align = "Right",
    --     horizontal_offset = "200px",
    --     repeat_x = "NoRepeat",
    --     repeat_y = "NoRepeat",
    --     -- width = "1431px",
    --     -- height = "1900px"
    -- },
}
