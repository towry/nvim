local plug = require('userlib.runtime.pack').plug

plug({
  'pze/leaf.nvim',
  event = 'User LazyTheme',
  dev = false,
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'leaf'),
  enabled = vim.cfg.ui__theme_name == 'leaf',
  opts = {
    overrides = {
      MiniCursorword = {
        style = "italic",
      },
      MiniCursorwordCurrent = {
        style = "bold"
      }
    }
  },
})
