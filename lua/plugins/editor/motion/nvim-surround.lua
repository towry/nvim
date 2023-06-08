local au = require('libs.runtime.au')

return {
  {
    "roobert/surround-ui.nvim",
    dependencies = {
      "kylechui/nvim-surround",
      "folke/which-key.nvim",
    },
    config = function()
      require("surround-ui").setup({
        root_key = "S"
      })
    end,
  },
  {
    'kylechui/nvim-surround',
    version = "*",
    event = au.user_autocmds.FileOpened_User,
    opts = {
      keymaps = {
        delete = 'dz',
      },
    },
    dependencies = {
      'roobert/surround-ui.nvim',
    }
  },
}
