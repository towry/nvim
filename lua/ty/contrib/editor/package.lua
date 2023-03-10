local pack = require('ty.core.pack').editor

pack({
  'Pocco81/true-zen.nvim',
  cmd = { 'TZNarrow', 'TZFocus', 'TZMinimalist', 'TZAtaraxis' },
  ImportOption = 'true_zen',
})

pack({
  'folke/todo-comments.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  ImportConfig = 'todo_comments',
})

pack({
  -- Whenever cursor jumps some distance or moves between windows, it will flash so you can see where it is.
  'DanilaMihailov/beacon.nvim',
  cmd = { 'Beacon' },
  ImportConfig = 'cursor_beacon',
  ImportInit = 'cursor_beacon',
})

pack({
  'luukvbaal/statuscol.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  cond = function() return vim.fn.has('nvim-0.9.0') == 1 end,
  ImportConfig = 'statuscol',
})

pack({
  'lukas-reineke/indent-blankline.nvim',
  event = 'BufReadPost',
  ImportConfig = 'indent_line',
})

pack({
  -- Blazing fast indentation style detection, I guess :)
  'NMAC427/guess-indent.nvim',
  event = 'InsertEnter',
  cmd = { 'GuessIndent' },
  ImportOption = 'guess_indent',
})

-- highlight the range when select in cmd line.
pack({
  'winston0410/range-highlight.nvim',
  dependencies = { 'winston0410/cmd-parser.nvim' },
  event = 'CmdLineEnter',
  config = true,
})

-- preview the line when using :<line-number> in cmd.
pack({
  'nacro90/numb.nvim',
  event = 'CmdLineEnter',
  config = true,
})

-- The dashboard !
pack({
  'goolord/alpha-nvim',
  cmd = { 'Alpha' },
  ImportConfig = 'dashboard',
})

-- Project rooter detect
pack({
  'notjedi/nvim-rooter.lua',
  event = { 'BufReadPost', 'BufNewFile' },
  ImportOption = 'rooter',
})

-- Session manage.
pack({
  'Shatur/neovim-session-manager',
  cmd = { 'SessionManager' },
  ImportConfig = 'session_manager',
  Feature = 'session',
})

-- Auto save last buffer position.
pack({
  'ethanholz/nvim-lastplace',
  event = { 'BufReadPre', 'BufNewFile' },
  ImportOption = 'buf_lastplace',
})
