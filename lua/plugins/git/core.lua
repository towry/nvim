local au = require('libs.runtime.au')

return {
  { 'kdheepak/lazygit.nvim', cmd = 'LazyGit' },
  {
    'tpope/vim-fugitive',
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
    event = au.user_autocmds.FileOpened,
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
