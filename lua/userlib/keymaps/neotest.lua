local M = {}

M.attach = function(bufnr)
  local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

  require('userlib.mini.clue').extend_clues({
    {
      mode = 'n',
      keys = '<localleader>t',
      desc = '+Tests',
    },
  })

  set('n', '<localleader>to', function()
    require('neotest').output.open({ enter = true, short = true })
  end, {
    desc = 'Neotest output',
  })
  set('n', '<localleader>tO', function()
    require('neotest').output_panel.toggle()
  end, {
    desc = 'Neotest output pane',
  })
  set('n', '<localleader>tt', function()
    require('neotest').run.run()
  end, {
    desc = 'Neotest run',
  })
  set('n', '<localleader>tk', function()
    require('neotest').run.stop()
  end, {
    desc = 'Neotest stop',
  })
  set('n', '<localleader>ts', function()
    require('neotest').summary.toggle()
  end, {
    desc = 'Noetest toggle summary',
  })
  set('n', '<localleader>tf', function()
    require('neotest').run.run(vim.fn.expand('%'))
  end, {
    desc = 'Neotest run file',
  })
end

return M
