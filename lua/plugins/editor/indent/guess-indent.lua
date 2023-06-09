return {
  'NMAC427/guess-indent.nvim',
  event = 'InsertEnter',
  cmd = { 'GuessIndent' },
  opts = {
    auto_cmd = true, -- Set to false to disable automatic execution
    filetype_exclude = vim.cfg.misc__ft_exclude,
    buftype_exclude = vim.cfg.misc__buf_exclude,
  }
}
