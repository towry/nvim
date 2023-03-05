local pack = require('ty.core.pack').navigate

-- go to definition etc.
pack({
  'hrsh7th/nvim-gtd',
  config = true,
})

-- leap motion
pack({
  'ggandor/leap.nvim',
  dependencies = {
    'tpope/vim-repeat',
  },
  keys = { { 's' }, { 'S' }, { 'gs' }, { 'f' }, { 'F' }, { 'vs' }, { 'ds' } },
  ImportConfig = 'leap',
})

-- scrolling
pack({
  'declancm/cinnamon.nvim',
  -- broken after upgraded neovim.
  enabled = false,
  event = { 'BufReadPost', 'BufNewFile' },
})

-- visualize jumplist.
pack({
  'cbochs/portal.nvim',
  dependencies = {
    'cbochs/grapple.nvim',
  },
  ImportConfig = 'portal',
})

pack({
  'cbochs/grapple.nvim',
  ImportOption = "grapple",
})

-- marks.
pack({
  'chentoast/marks.nvim',
  event = 'BufReadPost',
  ImportConfig = "marks",
})

-- jump html tags
pack({
  -- jump html tags.
  'harrisoncramer/jump-tag',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
})

-- prevent cursor from moving when using shift and filter actions.
pack({ 'gbprod/stay-in-place.nvim', config = true, event = 'BufReadPost' })

pack({
  'kylechui/nvim-surround',
  event = 'BufReadPost',
  ImportOption = 'surround',
})
