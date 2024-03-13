local map = require('userlib.runtime.keymap').map_buf_thunk(0)
local qf = require('userlib.runtime.qf')
if vim.fn.exists('&winfixbuf') == 1 then
  vim.cmd('setlocal winfixbuf')
end

map('n', 'q', '<cmd>cclose | lclose<cr>', { silent = true, nowait = true, noremap = true, desc = 'Close qf' })

local opt = vim.opt_local

opt.wrap = false
opt.cursorline = true
opt.number = false
opt.signcolumn = 'yes'
opt.buflisted = false
opt.winfixheight = true
opt.listchars:append('trail: ')
vim.b.minicursorword_disable = true

map('n', 'dd', qf.qf_delete, { desc = 'delete current quickfix entry' })
-- map('v', 'd', qf.qf_delete, { desc = 'delete selected quickfix entry' })
map('n', ',q', ':colder<CR>', { desc = 'qf: older' })
map('n', '.q', ':cnewer<CR>', { desc = 'qf: newer' })
map('n', '<C-r>', function()
  Ty.capture_tmux_pane(0)
  vim.defer_fn(function()
    vim.cmd('normal! G')
  end, 300)
end, {
  desc = 'qf: refresh dispatch',
})

-- force quickfix to open beneath all other splits
vim.cmd.wincmd('J')
require('userlib.runtime.buffer').adjust_split_height(6, 10)
