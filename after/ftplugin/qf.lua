local qf  = require('userlib.runtime.qf')
local map = vim.keymap.set
vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<cmd>cclose<cr>', { silent = true, nowait = true, noremap = true })

local opt = vim.opt_local

opt.wrap = false
opt.number = false
opt.signcolumn = 'yes'
opt.buflisted = false
opt.winfixheight = true

map('n', 'dd', qf.qf_delete, { desc = 'delete current quickfix entry', buffer = 0 })
map('v', 'd', qf.qf_delete, { desc = 'delete selected quickfix entry', buffer = 0 })
map('n', 'H', ':colder<CR>', { buffer = 0 })
map('n', 'L', ':cnewer<CR>', { buffer = 0 })
-- force quickfix to open beneath all other splits
vim.cmd.wincmd('J')
require('userlib.runtime.buffer').adjust_split_height(3, 10)
