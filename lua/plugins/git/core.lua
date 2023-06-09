local au = require('libs.runtime.au')
local cmdstr = require('libs.runtime.keymap').cmdstr

return {
  {
    'kdheepak/lazygit.nvim',
    cmd = 'LazyGit',
    keys = {
      {
        '<leader>gl', '<cmd>LazyGit<cr>', desc = 'Open Lazygit',
      }
    }
  },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gg', ":Git<cr>",               desc = "Fugitive Git" },
      { '<leader>ga', cmdstr([[!git add %:p]]), desc = "Git add current" },
      { '<leader>gA', cmdstr([[!git add .]]),   desc = "Git add all" },
    },
    cmd = {
      'G',
      'Git',
      'Gread',
      'Gwrite',
      'Ggrep',
      'GMove',
      'GDelete',
      'GBrowse',
      'Gdiffsplit',
      'Gvdiffsplit',
      'Gedit',
      'Gsplit',
    },
  },
  {
    --
    'shumphrey/fugitive-gitlab.vim',
    dependencies = {
      'tpope/vim-fugitive',
    },
  },
  {
    -- git runtimes. ft etc.
    'tpope/vim-git',
    event = au.user_autocmds.FileOpened_User,
    cond = function() return true end,
  },
  {
    -- tig like git commit browser.
    'junegunn/gv.vim',
    cmd = { 'GV' },
    dependencies = {
      'tpope/vim-fugitive',
    },
  },
}
