local au = require('libs.runtime.au')

return {
  'mawkler/modicator.nvim',
  cond = vim.o.termguicolors == true,
  opts = {},
  event = au.user_autocmds.FileOpened_User,
}
