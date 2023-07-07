local lodash = require('userlib.runtime.table')
---@param list_type "loclist" | "quickfix"
---@return boolean
local function is_list_open(list_type)
  return lodash.find(function(win) return not lodash.falsy(win[list_type]) end, vim.fn.getwininfo()) ~= nil
end

local M = {}

local silence = { mods = { silent = true, emsg_silent = true } }

function M.toggle_qf()
  if is_list_open('quickfix') then
    vim.cmd.cclose(silence)
  elseif #vim.fn.getqflist() > 0 then
    require('userlib.runtime.buffer').preserve_window(vim.cmd.copen, silence)
  end
end

function M.toggle_loc()
  if is_list_open('loclist') then
    vim.cmd.lclose(silence)
  elseif #vim.fn.getloclist(0) > 0 then
    require('').preserve_window(vim.cmd.lopen, silence)
  end
end

-- @see: https://vi.stackexchange.com/a/21255
-- using range-aware function
function M.qf_delete(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local list = vim.fn.getqflist()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local mode = vim.api.nvim_get_mode().mode
  if mode:match('[vV]') then
    local first_line = vim.fn.getpos("'<")[2]
    local last_line = vim.fn.getpos("'>")[2]
    list = lodash.fold(function(accum, item, i)
      if i < first_line or i > last_line then accum[#accum + 1] = item end
      return accum
    end, list)
  else
    table.remove(list, line)
  end
  -- replace items in the current list, do not make a new copy of it; this also preserves the list title
  vim.fn.setqflist({}, 'r', { items = list })
  vim.fn.setpos('.', { buf, line, 1, 0 }) -- restore current line
end

return M
