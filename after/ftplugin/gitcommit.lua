local bufnr = vim.api.nvim_get_current_buf()
local libutils = require('userlib.runtime.utils')
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<cmd>q<cr>', { silent = true, nowait = true, noremap = true })
vim.b[0].autoformat_disable = true
