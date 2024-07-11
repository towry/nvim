local keymap_cmd = require('v').keymap_cmd

return {
  'mrjones2014/smart-splits.nvim',
  event = 'VeryLazy',
  dependencies = {
    'kwkarlwang/bufresize.nvim',
  },
  keys = {
    {
      '<C-\\><C-r>h',
      mode = { 'n', 't' },
      keymap_cmd([[lua require("smart-splits").resize_left(vim.g.cfg_resize_steps)]]),
      desc = 'Start resize mode',
    },
    {
      '<C-\\><C-r>j',
      mode = { 'n', 't' },
      keymap_cmd([[lua require("smart-splits").resize_down(vim.g.cfg_resize_steps)]]),
      desc = 'Resize window to down',
    },
    {
      '<C-\\><C-r>k',
      mode = { 'n', 't' },
      keymap_cmd([[lua require("smart-splits").resize_up(vim.g.cfg_resize_steps)]]),
      desc = 'Resize window to up',
    },
    {
      '<C-\\><C-r>l',
      mode = { 'n', 't' },
      keymap_cmd([[lua require("smart-splits").resize_right(vim.g.cfg_resize_steps)]]),
      desc = 'Resize window to right',
    },

    {
      '<A-h>',
      keymap_cmd([[lua require("smart-splits").resize_left(vim.g.cfg_resize_steps)]]),
      desc = 'Resize window to left',
    },
    {
      '<A-j>',
      keymap_cmd([[lua require("smart-splits").resize_down(vim.g.cfg_resize_steps)]]),
      desc = 'Resize window to down',
    },
    {
      '<A-k>',
      keymap_cmd([[lua require("smart-splits").resize_up(vim.g.cfg_resize_steps)]]),
      desc = 'Resize window to up',
    },
    {
      '<A-l>',
      keymap_cmd([[lua require("smart-splits").resize_right(vim.g.cfg_resize_steps)]]),
      desc = 'Resize window to right',
    },
    {
      '<C-h>',
      keymap_cmd([[lua require("smart-splits").move_cursor_left()]]),
      desc = 'Move cursor to left window',
    },
    {
      '<C-j>',
      keymap_cmd([[lua require("smart-splits").move_cursor_down()]]),
      desc = 'Move cursor to down window',
    },
    {
      '<C-k>',
      keymap_cmd([[lua require("smart-splits").move_cursor_up()]]),
      desc = 'Move cursor to up window',
    },
    {
      '<C-l>',
      keymap_cmd([[lua require("smart-splits").move_cursor_right()]]),
      desc = 'Move cursor to right window',
    },
  },
  opts = function()
    return {
      default_amount = 3,
      -- Ignored filetypes (only while resizing)
      ignored_filetypes = {
        'nofile',
        'quickfix',
        'prompt',
        'qf',
      },
      -- Ignored buffer types (only while resizing)
      ignored_buftypes = { 'nofile', 'NvimTree' },
      resize_mode = {
        quit_key = {
          quit_key = '<ESC>',
          resize_keys = { 'h', 'j', 'k', 'l' },
        },
        hooks = {
          on_leave = function()
            require('bufresize').register()
          end,
        },
      },
      ignored_events = {
        'BufEnter',
        'WinEnter',
      },
      log_level = 'error',
      disable_multiplexer_nav_when_zoomed = true,
    }
  end,
}
