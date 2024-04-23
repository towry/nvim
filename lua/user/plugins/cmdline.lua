local pack = require('userlib.runtime.pack')

pack.plug({
  -- hightlights ranges you have entered in commandline.
  {
    'winston0410/range-highlight.nvim',
    cond = not vim.cfg.runtime__starts_as_gittool,
    dependencies = { 'winston0410/cmd-parser.nvim' },
    event = 'CmdLineEnter',
    config = true,
  },
  -- peeks lines of the buffer in non-obtrusive way.
  {
    'nacro90/numb.nvim',
    event = 'CmdLineEnter',
    config = false,
  },
})
