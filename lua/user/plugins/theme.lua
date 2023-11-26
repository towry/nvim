local plug = require('userlib.runtime.pack').plug

----- everforest
plug({
  'sainnhe/gruvbox-material',
  event = 'User LazyTheme',
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'gruvbox-material'),
  enabled = vim.cfg.ui__theme_name == 'gruvbox-material',
  init = function()
    vim.g.gruvbox_material_background = 'hard'
    vim.g.gruvbox_material_ui_contrast = 'low'
    vim.g.gruvbox_material_better_performance = 1
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_disable_italic_comment = false
    vim.g.gruvbox_material_transparent_background = false
    vim.g.gruvbox_material_dim_inactive_windows = false
    vim.g.gruvbox_material_sign_column_background = 'none'  -- "none" | "grey"
    vim.g.gruvbox_material_diagnostic_virtual_text = 'grey' -- "grey" | "colored"
    vim.g.gruvbox_material_diagnostic_text_highlight = 1
    vim.g.gruvbox_material_diagnostic_line_highlight = 1
    vim.g.gruvbox_material_current_word = 'underline'
  end
})


plug({
  'EdenEast/nightfox.nvim',
  dependencies = {
  },
  event = 'User LazyTheme',
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'nightfox'),
  enabled = vim.cfg.ui__theme_name == 'nightfox',
  opts = function()
    return {}
  end
})
