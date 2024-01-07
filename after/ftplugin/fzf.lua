local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

set('n', 'q', ':fclose<cr>', { nowait = true, silent = true })
set('n', '<C-q>', ':fclose<cr>', { nowait = true, silent = true })
set('n', '<ESC>', ':fclose<cr>', { nowait = true, silent = true })
set('t', '<C-a>', function()
  local cur_win = vim.api.nvim_get_current_win()
  require('flash').jump({
    pattern = '^',
    label = { after = { 0, 0 } },
    search = {
      mode = 'search',
      exclude = {
        function(win)
          return win ~= cur_win
        end,
      },
    },
    action = function(match)
      local pos = { match.pos[1], 0 }
      -- vim.api.nvim_win_set_cursor(0, { 8, 1 })
      local key = vim.api.nvim_replace_termcodes('3<Down>', true, false, true)
      vim.api.nvim_feedkeys(key, 't', false)
    end,
  })
end, { nowait = true })
