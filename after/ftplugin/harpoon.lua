-- harpoon.ui provided a api to nav_file by index
-- we want to bind key 1..9 to nav_file(1..9)
for i = 1, 9 do
  local key = tostring(i)
  local index = i
  vim.api.nvim_buf_set_keymap(
    0,
    'n',
    key,
    "<cmd>lua require('harpoon.ui').nav_file(" .. index .. ')<CR>',
    { noremap = true, silent = true, nowait = true }
  )
end
-- move cursor to the 10th item.
vim.api.nvim_buf_set_keymap(0, 'n', '0', 'gg10j', { expr = true, noremap = true, silent = true, nowait = true })
vim.wo.cursorline = true
