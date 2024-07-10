vim.b.minianimate_disable = true
vim.b.treesitter_disable = true
vim.opt_local.indentexpr = ''
-- vim.opt_local.statuscolumn = ''
vim.opt_local.colorcolumn = ''
vim.opt_local.cindent = false
vim.opt_local.ai = false
--- codeium.vim cause oil indent weird
vim.b.codeium_enabled = false

local bufnr = vim.api.nvim_get_current_buf()
local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)

local function open_file_in_win(pick_window)
  return function()
    local oil = require('oil')
    local entry = oil.get_cursor_entry()
    if entry.type ~= 'file' then
      return
    end
    local win = pick_window()
    if win then
      local lnum = vim.api.nvim_win_get_cursor(0)[1]
      local winnr = vim.api.nvim_win_get_number(win)
      vim.cmd(winnr .. 'windo buffer ' .. bufnr)
      vim.api.nvim_win_call(win, function()
        vim.api.nvim_win_set_cursor(win, { lnum, 1 })
        oil.select({
          close = false,
        }, function() end)
      end)
      return
    end
  end
end

set(
  'n',
  'go',
  open_file_in_win(function()
    local win = require('window-picker').pick_window({
      autoselect_one = true,
      -- hint = 'floating-big-letter',
      include_current_win = true,
    })
    return win
  end),
  {
    desc = 'Pick win to open file',
    nowait = true,
    noremap = true,
  }
)

set(
  'n',
  '<C-e>',
  open_file_in_win(function()
    local win = require('userlib.runtime.buffer').smart_open()
    return win or vim.api.nvim_get_current_win()
  end),
  {
    desc = 'Smart open',
    nowait = true,
    noremap = true,
  }
)

set('n', 's', function()
  require('flash').jump({
    search = {
      mode = 'search',
      max_length = 0,
      exclude = {
        function(win)
          return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'oil'
        end,
      },
    },
    label = { after = { 0, 0 }, style = 'inline' },
    pattern = '^',
  })
end, {
  nowait = true,
})

set('n', 'W', function()
  require('oil').open(vim.cfg.runtime__starts_cwd)
end, {
  nowait = true,
  desc = 'Open in root',
})
set('n', '_', function()
  require('oil').open(require('userlib.runtime.utils').get_root())
end, {
  nowait = true,
  desc = 'Open in project',
})
