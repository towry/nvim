local plug = require('userlib.runtime.pack').plug

----- everforest
plug({
  'sainnhe/everforest',
  event = 'User LazyTheme',
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'everforest'),
  enabled = vim.cfg.ui__theme_name == 'everforest',
  init = function()
    vim.g.everforest_background = 'soft'
    vim.g.everforest_ui_contrast = 'soft'
    vim.g.everforest_better_performance = 0
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_disable_italic_comment = false
    vim.g.everforest_transparent_background = false
    vim.g.everforest_dim_inactive_windows = false
    vim.g.everforest_sign_column_background = 'none'     -- "none" | "grey"
    vim.g.everforest_diagnostic_virtual_text = 'colored' -- "grey" | "colored"
    vim.g.everforest_diagnostic_text_highlight = 1
    vim.g.everforest_diagnostic_line_highlight = 1
    vim.g.everforest_current_word = 'underline'
  end
})


-- @see https://github.com/ellisonleao/gruvbox.nvim
plug({
  'ellisonleao/gruvbox.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'gruvbox'),
  cond = vim.cfg.ui__theme_name == 'gruvbox',
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

plug({
  'mcchrish/zenbones.nvim',
  dependencies = {
    'rktjmp/lush.nvim',
  },
  enabled = string.match(vim.cfg.ui__theme_name, 'zenbones') ~= nil,
  lazy = (not string.match(vim.cfg.ui__theme_name, 'bones') and (not string.match(vim.cfg.ui__theme_name, 'zen'))),
  priority = 1000,
  config = false,
  init = function()
    vim.g.neobones = {
      -- solid_line_nr = true,
      darken_comments = 45,
      solid_float_border = true,
    }
  end,
})
