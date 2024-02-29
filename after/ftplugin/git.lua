Ty.source_vimscripts('gf_diff.vim')
local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

vim.opt_local.relativenumber = false
-- do not show char after line ending.
vim.opt_local.listchars:append('trail: ')
vim.b[0].autoformat_disable = true
vim.bo.syntax = 'diff'
vim.opt_local.foldmethod = 'syntax'

--- copy file path from git view
--- press <enter> in the cmdline to yank
set('n', '<localleader>yp', function()
  Ty.feedkeys('.')
  --- wait until cmdline is fulfilled.
  vim.schedule(function()
    Ty.feedkeys('silent !echo<C-e> | pbcopy')
  end)
end, {
  desc = 'Yank the file path under the cursor in cmdline',
})
