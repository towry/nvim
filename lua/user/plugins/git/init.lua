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
    event = { 'BufReadPost', 'BufNewFile', 'BufWinEnter' },
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
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPost', 'BufNewFile', 'BufWinEnter' },
    config = function()
      require_plugin_spec('git.gitsigns.rc').config()
    end
  },
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewLog',
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewRefresh',
      'DiffviewFocusFile',
      'DiffviewFileHistory',
      'DiffviewToggleFiles',
    },
    config = function()
      require_plugin_spec('git.diffview.rc').config()
    end,
  },
  {
    'akinsho/git-conflict.nvim',
    tag = 'v1.0.0',
    cmd = {
      'GitConflictChooseBoth',
      'GitConflictNextConflict',
      'GitConflictChooseOurs',
      'GitConflictPrevConflict',
      'GitConflictChooseTheirs',
      'GitConflictListQf',
      'GitConflictChooseNone',
      'GitConflictRefresh',
    },
    config = function()
      require_plugin_spec('git.git_conflict.rc').config()
    end,
  },
  {
    'ThePrimeagen/git-worktree.nvim',
    config = function()
      require_plugin_spec('git.git_worktree.rc').config()
    end,
  },
}
