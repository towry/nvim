local M = {}

---@param opts {cwd?:string}
function M.toggle(opts)
  opts = opts or {}

  local Terminal = require('toggleterm.terminal').Terminal

  local gitu = Terminal:new({
    cmd = 'gitu',
    dir = opts.cwd,
    direction = 'float',
    close_on_exit = true,
    hidden = true,
    on_open = function()
      vim.cmd('startinsert!')
    end,
  })
  gitu:toggle()
end

return M
