local set = require('userlib.runtime.keymap').map_buf_thunk(0)
if vim.fn.exists('&winfixbuf') == 1 then
  vim.cmd('setlocal winfixbuf')
end

local mapopts = { nowait = true, noremap = true, silent = true }

set('n', 'l', '<cmd>wincmd l<cr>', mapopts)
set('n', 'h', '<cmd>wincmd l<cr>', mapopts)
set('n', '<ESC>', ':UndotreeHide<cr>', mapopts)
