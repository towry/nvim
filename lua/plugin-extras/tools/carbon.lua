local plug = require('userlib.runtime.pack').plug

return plug({
  'ellisonleao/carbon-now.nvim',
  lazy = true,
  vscode = true,
  cmd = 'CarbonNow',
  opts = {
    open_cmd = 'open',
    base_url = 'https://carbon.now.sh/',
    options = {
      theme = 'nord',
      font_family = 'JetBrains Mono',
      font_size = '16px',
    },
  },
  keys = {
    {
      '<leader>tc',
      ':CarbonNow<CR>',
      desc = 'Carbon code sharing',
      mode = 'v',
      silent = true,
    },
  },
})
