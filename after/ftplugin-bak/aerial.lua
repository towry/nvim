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

local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)
local curwin = vim.api.nvim_get_current_win()
set('n', 's', function()
  require('flash').jump({
    search = {
      mode = 'search',
      max_length = 0,
      exclude = {
        function(win)
          return win ~= curwin
        end,
      },
    },
    label = { after = { 0, 0 } },
    pattern = '^',
  })
end, {
  nowait = true,
})
