-- local wezterm = require 'wezterm'
-- wezterm already imported by home manager
local config = wezterm.config_builder()

config.color_scheme = 'Tokyo Night'

-- config.font = wezterm.font({ family = "gg sans mono" })
config.font_size = 16

config.keys = {
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bb',
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bf',
  },
  {
    key = 'LeftArrow',
    mods = 'SUPER',
    action = wezterm.action.SendString '\x01',
  },
  {
    key = 'RightArrow',
    mods = 'SUPER',
    action = wezterm.action.SendString '\x05',
  },
  {
    key = 'Backspace',
    mods = 'SUPER',
    action = wezterm.action.SendString '\x15',
  },
  {
    key = ',',
    mods = 'SUPER',
    action = wezterm.action.SpawnCommandInNewTab {
      cwd = wezterm.home_dir,
      args = { 'nvim', wezterm.config_file },
    },
  },
  -- Stop clearing your terminal
  {
    key = 'k',
    mods = 'SUPER',
    action = wezterm.action.Nop,
  },
  -- Jump between cmds
  { key = 'UpArrow', mods = 'SUPER', action = wezterm.action.ScrollToPrompt(-1) },
  { key = 'DownArrow', mods = 'SUPER', action = wezterm.action.ScrollToPrompt(1) },

}

config.use_fancy_tab_bar = false

config.window_decorations = "RESIZE"
config.window_padding = {
  left = 30,
  right = 30,
  top = 15,
  bottom = 15,
}

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

config.set_environment_variables = {
  PATH = os.getenv('HOME') .. '/.nix-profile/bin:' .. os.getenv('PATH')
}

return config
