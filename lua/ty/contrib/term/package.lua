local pack = require('ty.core.pack').term


pack({
  "willothy/flatten.nvim",
  enabled = false,
  ImportOption = "term_flatten",
})

pack({
  'akinsho/nvim-toggleterm.lua',
  cmd = { 'ToggleTerm' },
  branch = 'main',
  ImportInit = 'toggleterm',
  ImportConfig = 'toggleterm',
})
