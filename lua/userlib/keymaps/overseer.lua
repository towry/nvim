local M = {}

M.attach = function(bufnr)
  local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

  set('n', '<localleader>or', '<cmd>OverseerRun<cr>', {
    desc = "Overseer run"
  })
  set('n', '<localleader>oo', '<cmd>OverseerToggle<cr>', {
    desc = "Overseer toggle"
  })
end

return M
