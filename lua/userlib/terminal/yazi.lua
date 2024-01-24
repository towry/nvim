local M = {}

---@param opts {cwd?:string}
function M.toggle(opts)
  opts = opts or {}

  local Terminal = require('toggleterm.terminal').Terminal

  local yazi = Terminal:new({
    cmd = 'yazi',
    dir = opts.cwd,
    direction = 'tab',
    close_on_exit = true,
    hidden = true,
    on_open = function(term)
      vim.cmd('startinsert!')
    end,
  })
  yazi:toggle()
end

return M
