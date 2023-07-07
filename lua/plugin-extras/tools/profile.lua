local plug = require('userlib.runtime.pack').plug

return plug({
  {
    'dstein64/vim-startuptime',
    cond = function()
      return vim.env.PROFILE == 1
    end,
    lazy = false,
  }
})
