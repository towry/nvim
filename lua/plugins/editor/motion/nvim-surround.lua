local au = require('libs.runtime.au')

return {
  'kylechui/nvim-surround',
  event = au.user_autocmds.FileOpened_User,
  opts = {
    keymaps = {
      delete = 'dz',
    },
  }
}
