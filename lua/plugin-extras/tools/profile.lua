local plug = require('userlib.runtime.pack').plug

return plug({
  {
    'dstein64/vim-startuptime',
    cmd = { 'StartupTime' },
    lazy = vim.env.PROFILE ~= 1,
  }
})
