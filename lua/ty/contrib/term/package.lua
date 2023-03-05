local pack = require('ty.core.pack').term

pack({
  'akinsho/nvim-toggleterm.lua',
  cmd = { 'ToggleTerm' },
  branch = 'main',
  ImportInit = 'toggleterm',
  ImportConfig = 'toggleterm',
})
