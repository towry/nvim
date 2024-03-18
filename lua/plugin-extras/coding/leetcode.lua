local plug = require('userlib.runtime.pack').plug

local leet_arg = 'leet'

return plug({
  -- 'kawre/leetcode.nvim',
  'pze/leetcode.nvim',
  dev = false,
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
      translator = false,
      translate_problems = false,
    },
    injector = {},
    hooks = {},
    storage = {
      home = vim.fn.expand('~/.leetcode/src/problems'),
    },
  },
  config = function(_, opts)
    require('leetcode').setup(opts)

    require('userlib.legendary').register('leetcode', function(lg)
      local cmds = {
        { 'submit' },
        { 'daily' },
        { 'reset ' },
        { 'run' },
      }

      local commands = {}
      for _, cmd in ipairs(cmds) do
        table.insert(commands, {
          (':Leet %s'):format(cmd[1]),
          description = ('Leet %s'):format(cmd[2] or cmd[1]),
        })
      end

      lg.commands(commands)
    end)
  end,
})
