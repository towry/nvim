---@diagnostic disable: duplicate-set-field
local M = {}

-- setup dressing
M.setup_dressing = require('ty.contrib.ui.dressing-plug').setup_dressing
M.option_reticle = {}

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

function M.setup_noice()
  local routes = {}

  require('noice').setup({
    presets = {
      lsp_doc_border = false,
      inc_rename = false,
    },
    cmdline = {
      enabled = true,
      format = {
        cmdline = {
          pattern = '^:',
          icon = '',
        },
      },
    },
    messages = {
      enabled = false,
      view = 'notify',
      view_error = 'messages',
    },
    popupmenu = {
      enabled = false,
    },
    notify = {
      enabled = true,
    },
    lsp = {
      progress = {
        enabled = false,
      },
      override = {},
      hover = {
        enabled = false,
      },
      signature = {
        enabled = false,
      },
    },
    smart_move = {
      enabled = false,
    },
    routes = routes,
  })
end

return M
