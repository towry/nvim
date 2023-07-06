local pack = require('userlib.runtime.pack')

return pack.plug({
  {
    "folke/zen-mode.nvim",
    cmd = { 'ZenMode' },
    keys = {
      {
        '<leader>zz', '<cmd>ZenMode<cr>', desc = 'Toggle Zen Mode',
      }
    },
    opts = {}
  }
})
