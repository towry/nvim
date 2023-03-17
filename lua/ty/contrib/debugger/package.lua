local pack = require('ty.core.pack').debugger

--- for debugging and running task etc.

pack({
  -- https://github.com/stevearc/overseer.nvim
  -- TODO: finish.
  'stevearc/overseer.nvim',
  cmd = { 'OverseerRun', 'OverseerToggle' },
  config = true,
})

--- debugging.
pack({
  'mfussenegger/nvim-dap',
  dependencies = {
    { 'theHamsta/nvim-dap-virtual-text' },
    { 'rcarriga/nvim-dap-ui' },
  },
  ImportConfig = 'dap',
})

--- testing.
pack({
  'rcarriga/neotest',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'haydenmeade/neotest-jest',
  },
  ImportConfig = 'neotest',
})
