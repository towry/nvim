local pack = require('ty.core.pack').explorer

-- file tree.
pack({
  'kyazdani42/nvim-tree.lua',
  cmd = {
    'NvimTreeToggle',
    'NvimTreeFindFileToggle',
  },
  ImportConfig = 'nvim_tree',
})

--- outline
pack({
  'stevearc/aerial.nvim',
  cmd = 'AerialToggle',
  ImportOption = 'outline',
})

-- for explore lsp errors.
pack({
  'folke/trouble.nvim',
  cmd = { 'TroubleToggle', 'Trouble' },
  ImportConfig = 'trouble',
})

-- search and replace.
pack({
  'nvim-pack/nvim-spectre',
  ImportOption = 'search_spectre',
})

-- better quickfix
pack({
  -- https://github.com/kevinhwang91/nvim-bqf
  'kevinhwang91/nvim-bqf',
  ft = 'qf',
  dependencies = {
    { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
  }
})

pack({
  'ThePrimeagen/harpoon',
})
