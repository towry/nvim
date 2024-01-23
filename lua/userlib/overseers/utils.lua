local keymap = require('userlib.runtime.keymap')
local M = {}
local windows = {}
local count_windows = 0
---@type number?
local last_window
local get_size = function()
  return vim.o.lines * 0.7
end

local augroup = vim.api.nvim_create_augroup('overseer_user_open_on_start', {})

M.resize_windows_on_stack = function()
  local each_height = math.floor(vim.o.lines / count_windows)
  for _, window in pairs(windows) do
    vim.api.nvim_win_set_height(window, each_height)
  end
end

M.add_window_to_stack = function(bufnr)
  if not last_window or not vim.api.nvim_win_is_valid(last_window) then
    M.create_window(bufnr, 'topleft', get_size)
    return
  end
  vim.api.nvim_set_current_win(last_window)
  M.create_window(bufnr, 'topleft')
  M.resize_windows_on_stack()
end

M.create_window = function(bufnr, modifier, size)
  if size == nil then
    size = ''
  elseif type(size) == 'function' then
    size = size()
  end

  local set = keymap.map_buf_thunk(bufnr)
  set('n', 'q', '<cmd>q<cr>', { desc = 'quit' })

  local cmd = 'split'
  if modifier ~= '' then
    cmd = modifier .. ' ' .. size .. cmd
  end
  vim.cmd(cmd)

  local winid = vim.api.nvim_get_current_win()
  windows[bufnr] = winid
  last_window = winid
  count_windows = count_windows + 1
  vim.wo[winid].winfixwidth = true
  vim.wo[winid].winfixheight = true
  vim.wo[winid].wrap = true

  vim.api.nvim_create_autocmd('WinClosed', {
    group = augroup,
    pattern = tostring(winid),
    callback = function()
      windows[bufnr] = nil
      return true
    end,
  })
end

M.close_window = function(bufnr)
  local winid = windows[bufnr]
  windows[bufnr] = nil
  if not winid then
    return false
  end

  if not vim.api.nvim_win_is_valid(winid) then
    return false
  end

  vim.api.nvim_win_close(winid, false)
end

function M.get_last_task()
  local overseer = require('overseer')
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    return nil
  else
    return tasks[1]
  end
end

--- https://github.com/pianocomposer321/dotfiles-yadm/blob/d8f7da6c19095353eb43c5fa8023148cff4440f4/.config/nvim/lua/user/overseer_util.lua
function M.open_vsplit_last()
  local task = M.get_last_task()
  if task then
    local bufnr = task:get_bufnr()
    M.add_window_to_stack(bufnr)
    vim.api.nvim_win_set_buf(0, bufnr)
  end
end

return M
