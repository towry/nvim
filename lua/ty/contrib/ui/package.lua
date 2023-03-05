local pack = require('ty.core.pack').ui

pack({
  'ellisonleao/gruvbox.nvim',
  enabled = false,
  -- make sure we load this during startup if it is your main colorscheme
  lazy = false,
  -- make sure to load this before all the other start plugins
  priority = 1000,
  ImportConfig = 'gruvbo',
})

pack({
  'sainnhe/everforest',
  lazy = false,
  priority = 1000,
  ImportConfig = 'everforest',
})

--- libs.
---
pack({ 'kyazdani42/nvim-web-devicons', opts = { default = true } })
pack({ 'nvim-lua/popup.nvim' })
pack({
  'MunifTanjim/nui.nvim',
})
pack({
  'stevearc/dressing.nvim',
  ImportInit = 'dressing',
  ImportConfig = 'dressing',
})
pack({
  'rcarriga/nvim-notify',
  ImportConfig = 'notify',
  ImportInit = 'notify',
})
