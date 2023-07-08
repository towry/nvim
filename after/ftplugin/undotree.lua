-- vim.api.nvim_create_augroup('_hide_undotree', { clear = true })
-- vim.api.nvim_create_autocmd('WinLeave', {
--   group = '_hide_undotree',
--   once = true,
--   buffer = 0,
--   nested = false,
--   callback = function()
--     vim.schedule(function()
--       pcall(vim.cmd, 'UndotreeHide')
--     end)
--   end,
-- })
local mapopts = { nowait = true, noremap = true, silent = true, buffer = 0 }
vim.keymap.set('n', 'l', '<cmd>wincmd l<cr>', mapopts)
vim.keymap.set('n', 'h', '<cmd>wincmd l<cr>', mapopts)
