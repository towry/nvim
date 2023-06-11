return {
  'mawkler/modicator.nvim',
  cond = vim.o.termguicolors == true,
  opts = {},
  event = 'BufReadPost',
}
