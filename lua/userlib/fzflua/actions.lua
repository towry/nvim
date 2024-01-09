local M = {}
local wrap = vim.schedule_wrap

local function after_set_current_win()
  local win_pick = require('window-picker')
  local win_picked = win_pick.pick_window({
    autoselect_one = false,
    include_current_win = true,
  })
  if not win_picked then
    return false
  end
  vim.api.nvim_set_current_win(win_picked)
  return true
end

M.files_open_in_window = wrap(function(selected, opts)
  local actions = require('fzf-lua.actions')
  if not after_set_current_win() then
    return
  end
  actions.vimcmd_file('e', selected, opts)
end)

M.buffers_open_in_window = wrap(function(selected, opts)
  local actions = require('fzf-lua.actions')

  if not after_set_current_win() then
    return
  end
  actions.vimcmd_buf('b', selected, opts)
end)

M.buffers_open_default = wrap(function(selected, opts)
  local actions = require('fzf-lua.actions')
  local path = require('fzf-lua.path')
  local Buffer = require('userlib.runtime.buffer')

  if #selected > 1 then
    actions.vimcmd_buf('b', selected, opts)
    return
  end

  local entry = path.entry_to_file(selected[1], opts)
  if not entry.bufnr then
    return
  end
  assert(type(entry.bufnr) == 'number')

  Buffer.set_current_buffer_focus(entry.bufnr)
end)

--- TODO: finish this
M.flash = function(selected, opts)
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
      vim.api.nvim_win_call(cur_win, function()
        -- lcoal buf = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_cursor(cur_win, { 8, 0 })
      end)
    end,
  })
end

return M
