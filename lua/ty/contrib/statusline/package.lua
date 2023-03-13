local pack = require('ty.core.pack').statusline

pack({
  'nvim-lualine/lualine.nvim',
  dependencies = {
    {
      'pze/lualine-copilot',
      dev = false,
    }
  },
  event = { 'BufReadPre', 'BufNewFile' },
  ImportConfig = 'lualine',
})

pack({
  'b0o/incline.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  ImportConfig = 'incline',
})
