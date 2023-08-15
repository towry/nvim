local api = vim.api
local winid = vim.api.nvim_get_current_win()

api.nvim_set_option_value('spell', false, {
  win = winid,
})
api.nvim_set_option_value('foldcolumn', '0', {
  win = winid,
})
