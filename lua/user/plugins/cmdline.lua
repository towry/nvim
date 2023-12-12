local pack = require('userlib.runtime.pack')

pack.plug(
  {
    -- hightlights ranges you have entered in commandline.
    {
      'winston0410/range-highlight.nvim',
      dependencies = { 'winston0410/cmd-parser.nvim' },
      event = 'CmdLineEnter',
      vscode = true,
      config = true,
    },
    -- peeks lines of the buffer in non-obtrusive way.
    {
      'nacro90/numb.nvim',
      vscode = true,
      event = 'CmdLineEnter',
      config = false,
    },
  }
)
