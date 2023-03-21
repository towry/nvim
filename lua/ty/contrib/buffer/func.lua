local M = {}
---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

local function start_dashboard()
  vim.cmd('Alpha')
end

M.switch_to_buffer_by_index = function(i)
  local bufs = require('lualine.components.buffers').bufpos2nr
  local bufn = bufs[i]
  if bufn == nil then return vim.cmd('LualineBuffersJump! ' .. i) end
  local buf_win_id = unpack(vim.fn.win_findbuf(bufn))
  if buf_win_id ~= nil then
    vim.api.nvim_set_current_win(buf_win_id)
    return
  end
  return vim.cmd('LualineBuffersJump! ' .. i)
end

-- close buffer and keep window layout
M.close_buffer = function()
  require('mini.bufremove').delete(0)
  vim.schedule(function()
    if #require('ty.core.buffer').list_bufnrs() <= 0 then
      local cur_empty = require('ty.core.buffer').get_current_empty_buffer()
      start_dashboard()
      if cur_empty then
        vim.api.nvim_buf_delete(cur_empty, { force = true })
      end
    end
  end)
end

M.close_bufwin = function()
  vim.cmd('bdelete')
  vim.schedule(function()
    if #require('ty.core.buffer').list_bufnrs() <= 0 then
      local cur_empty = require('ty.core.buffer').get_current_empty_buffer()
      start_dashboard()
      if cur_empty then
        vim.api.nvim_buf_delete(cur_empty, { force = true })
      end
    end
  end)
end

M.move_cursor_to_window = function(dir_str)
  local ok, splits = pcall(require, 'smart-splits')
  if not ok then return end
  local method = 'move_cursor_' .. dir_str
  splits[method]()
end

M.resize_window_by = function(dir_str, delta)
  local ok, splits = pcall(require, 'smart-splits')
  if not ok then return end
  local method = 'resize_' .. dir_str
  splits[method](delta)
end

M.swap_buffer_to_window = function(dir_str, move_cursor)
  local ok, splits = pcall(require, 'smart-splits')
  if not ok then return end
  local method = 'swap_buf_' .. dir_str
  splits[method]({
    move_cursor = move_cursor,
  })
end

return M
