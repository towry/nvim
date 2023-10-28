local M = {}

M.attach = function(bufnr)
  local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

  set('n', '<localleader>or', '<cmd>OverseerRun<cr>', {
    desc = "Overseer run"
  })
  set('n', '<localleader>oo', '<cmd>OverseerToggle<cr>', {
    desc = "Overseer toggle"
  })
  set('n', '<localleader>oR', function()
    local overseer = require("overseer")
    local tasks = overseer.list_tasks({ recent_first = true })
    if vim.tbl_isempty(tasks) then
      vim.notify("No tasks found", vim.log.levels.WARN)
    else
      overseer.run_action(tasks[1], "restart")
    end
  end, {
    desc = 'Overseer restart last task',
  })
end

return M
