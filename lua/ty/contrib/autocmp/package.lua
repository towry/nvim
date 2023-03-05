local pack = require('ty.core.pack').autocmp
-- all about code auto completion etc.

pack({
  'L3MON4D3/LuaSnip',
  lazy = true,
  dependencies = { 'rafamadriz/friendly-snippets', 'saadparwaiz1/cmp_luasnip' },
})

-- nvim-cmp
pack({
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter', 'CmdlineEnter' },
  Feature = 'autocomplete',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'onsails/lspkind-nvim',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-calc',
    {
      'tzachar/cmp-tabnine',
      build = './install.sh',
    },
    'David-Kunz/cmp-npm',
    'saadparwaiz1/cmp_luasnip',
  },
  config = function() require('ty.contrib.autocmp.cmp_rc').setup_cmp() end,
})

pack({
  'pze/codeium.nvim',
  cmd = 'Codeium',
  dev = false,
  enabled = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  config = true,
})

-- autopairs
pack({
  'windwp/nvim-autopairs',
  -- lazy = false,
  event = { 'InsertEnter' },
  Feature = 'autocomplete',
  config = function() require('ty.contrib.autocmp.autopairs_rc').setup() end,
})
