local wezterm = require('wezterm')
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- Visual Settings
config.color_scheme = 'Dracula'
config.font = wezterm.font('FiraCode Nerd Font Mono')
config.font_size = 15
config.line_height = 1.1

animation_fps = 120    -- Set UI animations to 120fps
max_fps = 120         -- Set maximum refresh rate to 120fps

-- Window Settings
config.window_padding = {
    left = 4,
    right = 4,
    top = 4,
    bottom = 4,
}
-- Initial window size (choose one method):
config.initial_rows = 80
config.initial_cols = 200

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 0  -- Disable blur on macOS
config.text_background_opacity = 1.0     -- Make text background fully opaque

-- Background Settings
-- config.background = {
--     {
--         source = {
--             File = os.getenv('HOME') .. '/.config/wezterm/background.jpg',  -- Adjust path as needed
--         },
--         -- Opacity of the background image (0.0 - 1.0)
--         opacity = 0.35,
--         -- How to scale/position the image
--         horizontal_align = 'Center',
--         vertical_align = 'Middle',
--         -- Scaling options: 'Cover', 'Contain', 'Scale'
--         repeat_x = 'NoRepeat',
--         repeat_y = 'NoRepeat',
--         -- You can set a specific size if needed
--         -- width = '100%',
--         -- height = '100%',
--     },
-- }


-- Tab Bar Settings
enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

-- Copy Mode Settings
-- config.copy_mode_use_nvim = true
-- Use your regular Neovim config for copy mode
-- config.copy_mode_nvim_cmd = {
--     'nvim',
--     '--cmd', string.format('set runtimepath+=%s', os.getenv('HOME') .. '/.config/wezterm')
-- }

-- Default key binding for entering copy mode is CTRL-SHIFT-x
config.keys = {
    {
        key = 'x',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateCopyMode
    },
}

return config
