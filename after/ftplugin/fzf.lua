local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

set('n', 'q', ':fclose<cr>', { nowait = true, silent = true })
set('n', '<C-q>', ':fclose<cr>', { nowait = true, silent = true })
set('n', '<ESC>', ':fclose<cr>', { nowait = true, silent = true })
set('t', '<C-a>', function()
  require('flash').jump({
    pattern = '^',
    label = { after = { 0, 0 } },
    search = {
      mode = 'search',
      exclude = {
        function(win)
          return false
        end,
      },
    },
    action = function(match)
      vim.print(match)
      -- local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
      -- picker:set_selection(match.pos[1] - 1)
    end,
  })
end, { nowait = true })
