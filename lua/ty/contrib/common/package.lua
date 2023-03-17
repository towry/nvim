local pack = require('ty.core.pack').common

pack({
  'nvim-lua/plenary.nvim',
})
pack({
  'nvim-tree/nvim-web-devicons',
})

pack({
  -- free the leader key.
  -- 'anuvyklack/hydra.nvim',
  'pze/hydra.nvim',
})

pack({
  'folke/which-key.nvim',
  lazy = true,
  pin = true,
  ImportConfig = 'whichkey',
})

pack({
  'mrjones2014/legendary.nvim',
  pin = true,
  dependencies = {
    -- used for frecency sort
    'kkharji/sqlite.lua',
  },
  ImportConfig = 'legendary',
})

-- telescope
pack({
  'nvim-telescope/telescope.nvim',
  pint = true,
  cmd = { 'Telescope' },
  dependencies = {
    { 'nvim-lua/popup.nvim' },
    { 'nvim-lua/plenary.nvim' },
    { 'ThePrimeagen/git-worktree.nvim' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    {
      'tknightz/telescope-termfinder.nvim',
    },
  },
  ImportConfig = 'telescope',
})

-- mini library
pack({
  'echasnovski/mini.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  ImportConfig = 'mini',
  ImportInit = 'mini',
})

pack({
  -- If you've ever tried using the . command after a plugin map,
  -- you were likely disappointed to discover it only repeated the last native command inside that map, rather than the map as a whole.
  'tpope/vim-repeat',
  keys = { '.' },
})
