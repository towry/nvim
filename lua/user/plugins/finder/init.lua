return {
  ---Telescope
  {
    'nvim-telescope/telescope.nvim',
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
    config = function()
      require_plugin_spec('finder.telescope.setup').config()
    end
  },
  {
    'kyazdani42/nvim-tree.lua',
    cmd = {
      'NvimTreeToggle',
      'NvimTreeFindFileToggle',
      'NvimTreeFindFile',
    },
    config = function()
      require_plugin_spec('finder.nvim_tree').config()
    end,
  },
  {
    'simrat39/symbols-outline.nvim',
    cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen', 'SymbolsOutlineClose' },
    opts = function()
      return require_plugin_spec('finder.opts').code_outline
    end,
  },

  {
    'folke/trouble.nvim',
    cmd = { 'TroubleToggle', 'Trouble' },
    ImportConfig = 'trouble',
  },

  {
    'nvim-pack/nvim-spectre',
    opts = function()
      return require_plugin_spec('finder.opts').search_spectre
    end,
  },

  {
    -- https://github.com/kevinhwang91/nvim-bqf
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    dependencies = {
      { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
    },
  },

  {
    'ThePrimeagen/harpoon',
  },

  {
    "imNel/monorepo.nvim",
    opts = function()
      return require_plugin_spec('finder.opts').monorepo
    end,
  },

  {
    'hrsh7th/nvim-gtd',
    config = true,
  },
  {
    'mrjones2014/lua-gf.nvim',
    ft = 'lua'
  },
  {
    -- https://github.com/jinh0/eyeliner.nvim
    'jinh0/eyeliner.nvim',
    config = function()
      require_plugin_spec('finder.eyeliner.rc').config();
    end,
    keys = { { 'f' }, { 'F' }, { 't' }, { 'T' } },
  },
  {
    'ggandor/leap.nvim',
    dependencies = {
      'tpope/vim-repeat',
    },
    keys = { { 's' }, { 'S' }, { 'gs' }, { 'f' }, { 'F' }, { 'vs' }, { 'ds' } },
    config = function()
      require_plugin_spec('finder.leap.rc').config();
    end,
  },
  {
    'declancm/cinnamon.nvim',
    -- broken after upgraded neovim.
    enabled = false,
    event = { 'BufReadPost', 'BufNewFile', 'BufWinEnter' },
  },
  {
    'cbochs/portal.nvim',
    cmd = { 'Portal' },
    dependencies = {
      'cbochs/grapple.nvim',
    },
    config = function()
      require_plugin_spec('finder.portal.rc').config();
    end,
  },
  {
    'cbochs/grapple.nvim',
    cmd = { 'GrappleToggle', 'GrapplePopup', 'GrappleCycle' },
    opts = function()
      return require_plugin_spec('finder.opts').grapple
    end,
  },
  {
    'chentoast/marks.nvim',
    event = 'BufReadPost',
    config = function()
      require_plugin_spec('finder.marks.rc').config();
    end,
  },
  {
    -- jump html tags.
    'harrisoncramer/jump-tag',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
  { 'gbprod/stay-in-place.nvim', config = true, event = 'BufReadPost' },
  {
    'kylechui/nvim-surround',
    event = 'BufReadPost',
    opts = function()
      return require_plugin_spec('finder.opts').surround
    end,
  },
}
