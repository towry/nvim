local P = nil
local M = {}

local default_colorscheme = 'everforest'

M.init = function()
  require('ty.core.utils').try(
    function() vim.cmd('colorscheme ' .. require('ty.core.config').ui.theme.colorscheme or default_colorscheme) end,
    'error when loading colorscheme'
  )
  require('ty.core.autocmd').on_need_hl_update(require('ty.contrib.ui.on_need_hl_update'))
end

M.theme_gruvbox = {
  contrast = 'soft',
  reverse = true,
  get_palette = function() return require('gruvbox.palette').get_base_colors(nil, M.theme_gruvbox.contrast) end,
  colors = function()
    if P == nil then P = M.theme_gruvbox.get_palette() end

    return {
      scroll_handle = P.bg3,
      marks_sign = P.green,
      leap_match_fg = '#cc241d',
      leap_label_secondary = P.yellow,
      leap_label_primary_bg = P.neutral_yellow,
      leap_label_primary_fg = '#ffffff',
      murmur_guifg = P.fg1,
      murmur_guibg = P.bg1,
      incline_guifg = P.fg0,
      incline_guibg = P.fg4,
      beacon_guibg = P.yellow,
      winbar_guifg = P.yellow,
      portal_border_forward = P.bg2,
      portal_border_none = P.bg1,
      portal_label = P.red,
      bufferline_backgroud = P.red,
      nvim_tree_indent_marker_fg = P.bg2,
      indent_line_fg = P.bg1,
      lualine_filename_fg = P.fg0,
    }
  end,
}
M.theme_everforest = {
  contrast = 'medium',
  better_performance = 1,
  get_palette = function()
    local configuration = vim.fn['everforest#get_configuration']()
    local palette = vim.fn['everforest#get_palette'](configuration.background, configuration.colors_override)

    if configuration.transparent_background == 2 then palette.bg1 = palette.none end

    return palette
  end,
  colors = function()
    if P == nil then P = M.theme_everforest.get_palette() end
    return {
      scroll_handle = P.bg3[1],
      marks_sign = P.green[1],
      leap_match_fg = '#DF69BA',
      leap_label_secondary = P.green[1],
      leap_label_primary_bg = P.purple[1],
      leap_label_primary_fg = '#ffffff',
      murmur_guifg = P.fg[1],
      murmur_guibg = P.bg1[1],
      incline_guifg = P.fg[1],
      incline_guibg = P.grey2[1],
      beacon_guibg = P.bg_yellow[1],
      winbar_guifg = P.bg_yellow[1],
      portal_border_forward = P.bg2[1],
      portal_border_none = P.bg1[1],
      portal_label = P.bg_red[1],
      bufferline_backgroud = P.bg_red[1], -- deprecated.
      nvim_tree_indent_marker_fg = P.bg1[1],
      indent_line_fg = P.bg1[1],
      lualine_filename_fg = P.fg[1],
    }
  end,
}

M.plugins = {
  lualine = {
    theme = 'everforest',
    theme_dep = 'sainnhe/everforest',
    -- theme = "gruvbox"
  },
}

function M.colors() return M['theme_' .. Ty.Config.ui.theme.colorscheme].colors() end

return M
