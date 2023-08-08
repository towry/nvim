vim.b.minianimate_disable = true
vim.opt.spell = false

local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

set('n', '<S-q>', function()
  require('oil').close()
end, {
  desc = 'Close oil',
})


set('n', 's', function()
  require('flash').jump({
    search = {
      mode = "search",
      max_length = 0,
      exclude = {
        function(win)
          return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "oil"
        end,
      }
    },
    label = { after = { 0, 0 } },
    pattern = "^"
  })
end, {
  nowait = true,
})
