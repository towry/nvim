local map = require('userlib.runtime.keymap').map_buf_thunk(0)
local qf = require('userlib.runtime.qf')

map('n', 'q', '<cmd>cclose | lclose<cr>', { silent = true, nowait = true, noremap = true, desc = 'Close qf' })

local opt = vim.opt_local

opt.wrap = false
opt.cursorline = true
opt.number = false
opt.signcolumn = 'yes'
opt.buflisted = false
opt.winfixheight = true
vim.b.minicursorword_disable = true

map('n', 'dd', qf.qf_delete, { desc = 'delete current quickfix entry' })
map('v', 'd', qf.qf_delete, { desc = 'delete selected quickfix entry' })
map('n', 'H', ':colder<CR>', { desc = 'qf: older' })
map('n', 'L', ':cnewer<CR>', { desc = 'qf: newer' })
-- force quickfix to open beneath all other splits
vim.cmd.wincmd('J')
require('userlib.runtime.buffer').adjust_split_height(6, 10)
