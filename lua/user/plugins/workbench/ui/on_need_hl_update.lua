-- local utils = require('ty.core.utils')

return function()
  local colors = require('ty.contrib.ui').colors()
  -- auto cmp cursor line hl.
  vim.api.nvim_set_hl(0, 'CmpMenuSel', {
    bg = '#a7c080',
    fg = '#ffffff',
    bold = true,
  })

  vim.api.nvim_set_hl(0, 'NvimTreeIndentMarker', {
    fg = colors.nvim_tree_indent_marker_fg,
  })

  -- utils.extend_hl('DiagnosticHint', {
  --   undercurl = false,
  -- })
  -- utils.extend_hl('DiagnosticInfo', {
  --   undercurl = false,
  -- })
  -- utils.extend_hl('DiagnosticWarn', {
  --   undercurl = false,
  -- })
  -- utils.extend_hl('DiagnosticError', {
  --   undercurl = false,
  -- })
end
