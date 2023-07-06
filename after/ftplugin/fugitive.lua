vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':bd<cr>', { nowait = true, noremap = true, silent = true })
-- vim.api.nvim_buf_set_keymap(0, 'n', 'cc', "", {
--   callback = function()
--     require('userlib.runtime.utils').load_plugins({ 'committia.vim' })
--     vim.fn['committia#open']('git')
--   end,
--   nowait = true,
--   noremap = true,
--   silent = true,
-- })
