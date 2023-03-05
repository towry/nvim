return function()
  -- auto cmp cursor line hl.
  vim.api.nvim_set_hl(0, 'CmpMenuSel', {
    bg = '#a7c080',
    fg = '#ffffff',
    bold = true,
  })
end
