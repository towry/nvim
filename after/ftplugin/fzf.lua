local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

set('n', 'q', ':fclose<cr>', { nowait = true, silent = true })
set('n', '<C-q>', ':fclose<cr>', { nowait = true, silent = true })
set('n', '<ESC>', ':fclose<cr>', { nowait = true, silent = true })
