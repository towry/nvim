local plug = require('userlib.runtime.pack').plug

return plug({
  'ellisonleao/carbon-now.nvim',
  lazy = true,
  cmd = 'CarbonNow',
  opts = {
    options = {
      font_family = "JetBrains Mono"
    }
  },
  keys = {
    {
      '<leader>tc',
      ":CarbonNow<CR>",
      desc = 'Carbon code sharing',
      mode = 'v',
      silent = true,
    }
  }
})
