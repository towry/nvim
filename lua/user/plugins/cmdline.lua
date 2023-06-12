local pack = require('libs.runtime.pack')

pack.plug(
  {
    -- hightlights ranges you have entered in commandline.
    {
      'winston0410/range-highlight.nvim',
      dependencies = { 'winston0410/cmd-parser.nvim' },
      event = 'CmdLineEnter',
      config = true,
    },
    -- peeks lines of the buffer in non-obtrusive way.
    {
      'nacro90/numb.nvim',
      event = 'CmdLineEnter',
      config = true,
    },
  }
)
