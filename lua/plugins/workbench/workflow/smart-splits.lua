local cmdstr = require('libs.runtime.keymap').cmdstr

return {
  'mrjones2014/smart-splits.nvim',
  keys = {
    { '<A-h>', cmdstr([[lua require("smart-splits").resize_left()]]),       desc = 'Resize window to left' },
    { '<A-j>', cmdstr([[lua require("smart-splits").resize_down()]]),       desc = 'Resize window to down' },
    { '<A-k>', cmdstr([[lua require("smart-splits").resize_up()]]),         desc = 'Resize window to up' },
    { '<A-l>', cmdstr([[lua require("smart-splits").resize_right()]]),      desc = 'Resize window to right' },
    { '<C-h>', cmdstr([[lua require("smart-splits").move_cursor_left()]]),  desc = 'Move cursor to left window' },
    { '<C-j>', cmdstr([[lua require("smart-splits").move_cursor_down()]]),  desc = 'Move cursor to down window' },
    { '<C-k>', cmdstr([[lua require("smart-splits").move_cursor_up()]]),    desc = 'Move cursor to up window' },
    { '<C-l>', cmdstr([[lua require("smart-splits").move_cursor_right()]]), desc = 'Move cursor to right window' },
  },
  dependencies = {
    'kwkarlwang/bufresize.nvim',
  },
  build = "./kitty/install-kittens.bash",
  config = function()
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
      log_level = "error",
      disable_multiplexer_nav_when_zoomed = true,
    })
  end,
}
