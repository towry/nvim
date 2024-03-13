local api = vim.api
local winid = vim.api.nvim_get_current_win()
vim.b.minicursorword_disable = true
vim.b.stl_foldlevel = false
vim.wo.number = true
vim.wo.relativenumber = true

api.nvim_set_option_value('spell', false, {
  win = winid,
})
api.nvim_set_option_value('foldcolumn', '0', {
  win = winid,
})
if vim.fn.exists('&winfixbuf') == 1 then
  vim.cmd('setlocal winfixbuf')
end
