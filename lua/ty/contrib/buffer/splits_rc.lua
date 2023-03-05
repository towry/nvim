local M = {}

M.setup_smart_splits = function()
  local splits = require("smart-splits")

  splits.setup({
    -- Ignored filetypes (only while resizing)
    ignored_filetypes = {
      'nofile',
      'quickfix',
      'prompt',
      'qf',
    },
    -- Ignored buffer types (only while resizing)
    ignored_buftypes = { 'nofile', 'NvimTree', },
    resize_mode = {
      quit_key = {
        quit_key = '<ESC>',
        resize_keys = { 'h', 'j', 'k', 'l' },
      },
      hooks = {
        on_leave = function() require('bufresize').register() end,
      },
    },
    ignored_events = {
      'BufEnter',
      'WinEnter',
    },
    tmux_integration = true,
    disable_tmux_nav_when_zoomed = true,
  })
end

return M
