return {
  'doums/dmap.nvim',
  event = { 'LspAttach' },
  opts = {
    ignore_filetypes = vim.cfg.misc__ft_exclude,
  }
}
