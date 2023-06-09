return {
  'williamboman/mason.nvim',
  cmd = { 'Mason', },
  opts = {
    PATH = 'prepend',
    ui = {
      -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
      border = vim.cfg.ui__float_border,
    },
  }
}
