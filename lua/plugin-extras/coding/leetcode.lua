local plug = require('userlib.runtime.pack').plug

local leet_arg = 'leet'

return plug({
  'kawre/leetcode.nvim',
  cmd = { 'Leet' },
  lazy = leet_arg ~= vim.fn.argv()[1],
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim', -- telescope 所需
    'MunifTanjim/nui.nvim',
  },
  opts = {
    arg = leet_arg,
    lang = 'rust',
    -- 配置放在这里
    cn = {
      enabled = true,
    },
    storage = {
      home = vim.fn.expand('~/.leetcode/src/problems'),
    },
  },
})
