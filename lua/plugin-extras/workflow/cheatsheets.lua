local plug = require('libs.runtime.pack').plug
local au = require('libs.runtime.au')

return plug({
  {
    'pze/cheatsheet.nvim',
    dev = false,
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    event = {
      au.user_autocmds.TelescopeConfigDone_User,
    },
    cmd = 'Cheatsheet',
    opts = {
      bundled_plugin_cheatsheets = false,
      bundled_cheatsheets = false,
      include_only_installed_plugins = true,
    },
    config = function(_, opts)
      require('cheatsheet').setup(opts)
      require('telescope').load_extension('cheatsheet')
    end,
  },
  {
    'RishabhRD/nvim-cheat.sh',
    cmd = { 'Cheat', 'CheatWithoutComments', 'CheatList', 'CheatListWithoutComments' },
    dependencies = {
      'RishabhRD/popfix',
    },
    init = function() vim.g.cheat_default_window_layout = 'vertical_split' end,
  },
})
