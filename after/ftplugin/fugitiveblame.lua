local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

vim.cmd('set colorcolumn=')

set('n', 'q', function()
  local wc = vim.api.nvim_tabpage_list_wins(0)
  if #wc == 1 then
    vim.cmd('bd')
  else
    vim.cmd('q')
  end
end, {
  desc = 'Close',
  nowait = true,
})
