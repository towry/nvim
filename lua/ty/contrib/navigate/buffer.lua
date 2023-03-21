local Buffer = require('ty.core.buffer')
local M = {}

M.next_unsaved_buf = function()
  local unsaved_buffers = Buffer.unsaved_list()
  if #unsaved_buffers <= 0 then
    vim.notify("No unsaved buffer", vim.log.levels.WARN)
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()

  local current_buf_index = vim.fn.index(unsaved_buffers, current_buf)
  if current_buf_index < 0 then
    current_buf_index = 0
  end

  local next_buf_index = current_buf_index + 1
  if next_buf_index > #unsaved_buffers then
    next_buf_index = 1
  end
  local next_buf = unsaved_buffers[next_buf_index]
  if not next_buf or next_buf < 1 then return end
  vim.api.nvim_set_current_buf(next_buf)
end

M.prev_unsaved_buf = function()
  local unsaved_buffers = Buffer.unsaved_list()
  if #unsaved_buffers <= 0 then
    vim.notify("No unsaved buffer", vim.log.levels.WARN)
    return
  end
  local current_buf = vim.api.nvim_get_current_buf()

  local current_buf_index = vim.fn.index(unsaved_buffers, current_buf)
  if current_buf_index < 0 then
    current_buf_index = 2
  end

  local prev_buf_index = current_buf_index - 1
  if prev_buf_index < 1 then
    prev_buf_index = #unsaved_buffers
  end
  local prev_buf = unsaved_buffers[prev_buf_index]
  if not prev_buf or prev_buf < 1 then return end
  vim.api.nvim_set_current_buf(prev_buf)
end

return M
