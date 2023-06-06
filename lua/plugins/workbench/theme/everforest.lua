return {
  'sainnhe/everforest',
  lazy = vim.cfg.ui__theme_name ~= 'everforest',
  enabled = vim.cfg.ui__theme_name == 'everforest',
  priority = 1000,
  init = function()
    vim.g.everforest_background = 'medium'
    vim.g.everforest_ui_contrast = 'low'
    vim.g.everforest_better_performance = 1
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_disable_italic_comment = false
    vim.g.everforest_transparent_background = false
    vim.g.everforest_dim_inactive_windows = false
    vim.g.everforest_sign_column_background = 'none'  -- "none" | "grey"
    vim.g.everforest_diagnostic_virtual_text = 'grey' -- "grey" | "colored"
    vim.g.everforest_diagnostic_text_highlight = 0
    vim.g.everforest_diagnostic_line_highlight = 0

    vim.cmd('colorscheme everforest')
  end
}
