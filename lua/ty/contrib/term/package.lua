local pack = require('ty.core.pack').term


pack({
  "willothy/flatten.nvim",
  enabled = false,
  ImportOption = "term_flatten",
})

pack({
  'akinsho/nvim-toggleterm.lua',
  cmd = { 'ToggleTerm', 'TermExec', },
  branch = 'main',
  tag = "v2.2.1",
  ImportInit = 'toggleterm',
  ImportConfig = 'toggleterm',
})
