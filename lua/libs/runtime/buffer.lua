local Table = require('libs.runtime.table')
local M = {}

function M.set_options(buf, opts)
  for k, v in pairs(opts) do
    vim.api.nvim_buf_set_option(buf, k, v)
  end
end

-- see https://github.com/nathanlc/dotfiles/blob/4eab9adac18965899fbeec0e6b0201997a3668fe/nvim/lua/utils/buffer.lua
---@return table<number, string> map of buffer number to buffer name
function M.list()
  local all_buffers = vim.api.nvim_list_bufs()
  local valid_buffers = Table.filter(function(b)
    if b == 0 then
      return false
    end
    if vim.api.nvim_buf_get_name(b) == "" then
      return false
    end

    return vim.api.nvim_buf_is_loaded(b)
  end, all_buffers)

  return Table.reduce(function(nrNameMap, b)
    nrNameMap[b] = vim.api.nvim_buf_get_name(b)

    return nrNameMap
  end, {}, valid_buffers)
end

---@param extra_filter? function bufnr
function M.list_bufnrs(extra_filter)
  local all_buffers = vim.api.nvim_list_bufs()
  local valid_buffers = Table.filter(function(b)
    if b == 0 then
      return false
    end
    if vim.api.nvim_buf_get_name(b) == "" then
      return false
    end

    if extra_filter and extra_filter(b) == false then
      return false
    end

    return vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_is_loaded(b)
  end, all_buffers)
  return valid_buffers
end

--- Get buf numbers of normal files.
function M.list_normal_bufnrs()
  return M.list_bufnrs(function(b)
    if vim.api.nvim_get_option_value('buftype', {
          buf = b,
        }) ~= '' then
      return false
    end
  end)
end

--- filter buffers
function M.filter_bufnrs(filter)
  local all_buffers = vim.api.nvim_list_bufs()
  return Table.filter(function(b)
    return filter(b)
  end, all_buffers)
end

---@param callback function carry, bufnr
function M.reduce_bufnrs(callback, carry)
  local all_buffers = vim.api.nvim_list_bufs()
  return Table.reduce(callback, carry, all_buffers)
end

---@return table<number> list of buffer numbers
function M.unsaved_list()
  local all_buffers = vim.api.nvim_list_bufs()
  local valid_buffers = Table.filter(function(b)
    if b == 0 then
      return false
    end
    if vim.api.nvim_buf_get_name(b) == "" then
      return false
    end

    local is_modified = vim.api.nvim_get_option_value("modified", {
      buf = b,
    })
    if not is_modified then
      return false
    end

    return vim.api.nvim_buf_is_loaded(b)
  end, all_buffers)
  return valid_buffers
end

---@return number|nil buffer number
function M.get_current_empty_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  -- local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local ft = vim.api.nvim_get_option_value("filetype", {
    buf = bufnr,
  })
  if name == '' and ft == '' then
    return bufnr
  end
  return nil
end

function M.getfsize(bufnr)
  local file = nil
  if bufnr == nil then
    file = vim.fn.expand('%:p')
  else
    file = vim.api.nvim_buf_get_name(bufnr)
  end

  local size = vim.fn.getfsize(file)
  if size <= 0 then
    return 0
  end
  return size
end

-- set the current buffer, if already showed in visible windows,
-- switch focus to it's window.
function M.set_current_buffer_focus(bufnr)
  local buf_win_id = unpack(vim.fn.win_findbuf(bufnr))
  if buf_win_id ~= nil then
    vim.api.nvim_set_current_win(buf_win_id)
    return
  end

  vim.api.nvim_set_current_buf(bufnr)
end

M.next_unsaved_buf = function()
  local unsaved_buffers = M.unsaved_list()
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

  M.set_current_buffer_focus(next_buf)
  -- vim.api.nvim_set_current_buf(next_buf)
end

M.prev_unsaved_buf = function()
  local unsaved_buffers = M.unsaved_list()
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
  M.set_current_buffer_focus(prev_buf)
  -- vim.api.nvim_set_current_buf(prev_buf)
end


return M
