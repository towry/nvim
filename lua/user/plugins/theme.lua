local plug = require('libs.runtime.pack').plug

----- everforest
plug({
  'towry/everforest',
  event = 'User LazyTheme',
  enabled = vim.cfg.ui__theme_name == 'everforest',
  init = function()
    vim.g.everforest_background = 'medium'
    vim.g.everforest_ui_contrast = 'high'
    vim.g.everforest_better_performance = 0
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_disable_italic_comment = false
    vim.g.everforest_transparent_background = false
    vim.g.everforest_dim_inactive_windows = false
    vim.g.everforest_sign_column_background = 'none' -- "none" | "grey"
    vim.g.everforest_diagnostic_virtual_text = 'grey' -- "grey" | "colored"
    vim.g.everforest_diagnostic_text_highlight = 1
    vim.g.everforest_diagnostic_line_highlight = 1
    vim.g.everforest_current_word = 'underline'
  end
})

plug({
  'mcchrish/zenbones.nvim',
  -- "towry/zenbones.nvim",
  -- dev = true,
  dependencies = {
    'rktjmp/lush.nvim',
    {
      cmd = { 'Shipwright' },
      'rktjmp/shipwright.nvim',
      lazy = true,
    },
  },
  event = 'User LazyTheme',
  enabled = string.match(vim.cfg.ui__theme_name, 'bones') ~= nil,
  config = false,
  init = function()
    vim.g.neobones = {
      solid_float_border = false,
      colorize_diagnostic_underline_text = true,
      transparent_background = false,
      -- light
      -- darken_comments = 30,
      lightness = 'dim',
      darken_cursor_line = 10,
      --- dark
      lighten_cursor_line = 15,
      -- lighten_comments = 30,
      lighten_non_text = 22,
    }
    vim.g.forestbones = {
      solid_float_border = false,
      colorize_diagnostic_underline_text = true,
      transparent_background = false,
      -- light
      -- darken_comments = 30,
      lightness = 'dim',
      darken_cursor_line = 10,
      --- dark
      lighten_cursor_line = 15,
      -- lighten_comments = 30,
      lighten_non_text = 22,
    }
  end,
})
