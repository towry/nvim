local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

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
set('n', '<leader>gp', function()
  vim.cmd([[Dispatch! Git push]])
end, {
  desc = 'Push',
})

-- vim.api.nvim_buf_set_keymap(0, 'n', 'cc', "", {
--   callback = function()
--     require('userlib.runtime.utils').load_plugins({ 'committia.vim' })
--     vim.fn['committia#open']('git')
--   end,
--   nowait = true,
--   noremap = true,
--   silent = true,
-- })
