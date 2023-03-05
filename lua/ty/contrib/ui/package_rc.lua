local M = {}

-- setup dressing
M.setup_dressing = require('ty.contrib.ui.dressing-plug').setup_dressing
M.init_dressing = require('ty.contrib.ui.dressing-plug').init_dressing

function M.setup_gruvbox()
  local theme = require('ty.contrib.ui').theme_gruvbox
  local colors = theme.get_palette()

  require('gruvbox').setup({
    undercurl = true,
    underline = true,
    dim_inactive = true,
    transparent_mode = false,
    inverse = theme.reverse,
    contrast = theme.contrast,
    overrides = {
      CmpMenuSel = { bg = colors.neutral_yellow, fg = '#ffffff', bold = true },
      Search = { italic = true, underline = true, undercurl = false, reverse = false },
      TabLineSel = { bg = colors.red },
      -- FoldColumn = { bg = colors.bg0, },
      -- SignColumn = { bg = colors.bg0, },
      Folded = { fg = colors.fg1, bg = colors.bg3, italic = true },
    },
  })
end

function M.setup_everforest()
  -- @see https://github.com/sainnhe/everforest/blob/master/doc/everforest.txt
  local theme = require('ty.contrib.ui').theme_everforest
  local config = require('ty.core.config').ui

  vim.g.everforest_background = theme.contrast
  vim.g.everforest_better_performance = config:get('theme_everforest.better_performance', 0)
  vim.g.everforest_enable_italic = config:get('theme_everforest.italic', 1)
  vim.g.everforest_disable_italic_comment = true
  vim.g.everforest_transparent_background = false
  vim.g.everforest_dim_inactive_windows = false
  vim.g.everforest_sign_column_background = 'none' -- "none" | "grey"
  vim.g.everforest_ui_contrast = 'low' -- contrast of line numbers, indent lines etc. "low" | "high"
  vim.g.everforest_diagnostic_virtual_text = 'grey' -- "grey" | "colored"

  vim.api.nvim_set_hl(0, 'CmpMenuSel', {
    bg = '#a7c080',
    fg = '#ffffff',
    bold = true,
  })
end

function M.init_notify()
  require('ty.core.autocmd').on_very_lazy(function() vim.notify = require('notify') end)
end
function M.setup_notify()
  require('notify').setup({
    timeout = '3000',
    max_width = function() return math.floor(vim.o.columns * 0.75) end,
    max_height = function() return math.floor(vim.o.lines * 0.75) end,
    on_open = function(win)
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_set_config(win, { border = 'rounded' }) end
    end,
    render = function(...)
      -- local notif = select(2, ...)
      local style = 'default'
      -- local style = notif.title[1] == '' and 'default' or 'default'
      require('notify.render')[style](...)
    end,
  })
end

return M
