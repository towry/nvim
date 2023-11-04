local plug = require('userlib.runtime.pack').plug

----- everforest
plug({
  'sainnhe/gruvbox-material',
  event = 'User LazyTheme',
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'gruvbox-material'),
  enabled = vim.cfg.ui__theme_name == 'gruvbox-material',
  init = function()
    vim.g.gruvbox_material_background = 'soft'
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


-- @see https://github.com/ellisonleao/gruvbox.nvim
plug({
  'ellisonleao/gruvbox.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'gruvbox'),
  enabled = vim.cfg.ui__theme_name == 'gruvbox',
  opts = function()
    local P = require('gruvbox').palette
    local color = function(dark, light)
      light = light or dark
      return vim.opt.background:get() == 'dark' and dark or light
    end
    return {
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
        contrast = "soft",
      },
      overrides = {
        -- CursorLine = { bg = color(P.dark2, P.light2) },
        CursorLineNr = { fg = color(P.neutral_yellow), bg = color(P.dark3, P.light3) },
        TelescopeSelection = { link = "CursorLineNr" },
      }
    }
  end
})
