local pack = require('ty.core.pack').git

pack({ 'kdheepak/lazygit.nvim', cmd = 'LazyGit' })
pack({
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
})
pack({
  --
  'shumphrey/fugitive-gitlab.vim',
  dependencies = {
    'tpope/vim-fugitive',
  },
})
pack({
  -- git runtimes. ft etc.
  'tpope/vim-git',
  -- TODO check is git repo.
  cond = function() return true end,
  event = 'VeryLazy',
})
pack({
  -- tig like git commit browser.
  'junegunn/gv.vim',
  cmd = { 'GV' },
  dependencies = {
    'tpope/vim-fugitive',
  },
})
pack({
  'lewis6991/gitsigns.nvim',
  dependencies = {
    -- "petertriho/nvim-scrollbar"
  },
  event = { 'BufReadPost', 'BufNewFile' },
  ImportConfig = 'gitsigns',
})
pack({
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
  ImportConfig = "diffview",
})

pack({
  'akinsho/git-conflict.nvim',
  cmd = {
    'GitConflictChooseBoth',
    'GitConflictNextConflict',
    'GitConflictChooseOurs',
    'GitConflictPrevConflict',
    'GitConflictChooseTheirs',
  },
  ImportConfig = 'git_conflict',
})

pack({
  'ThePrimeagen/git-worktree.nvim',
  ImportConfig = 'git_worktree',
})
