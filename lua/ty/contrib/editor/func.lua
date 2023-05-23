local utils = require('ty.core.utils')
local M = {}

M.save_current_session = function()
  vim.cmd([[SessionManager save_current_session]])
  Ty.NOTIFY("Session saved")
end
M.load_last_session = function()
  vim.cmd([[SessionManager load_last_session]])
  Ty.NOTIFY("Session loaded last")
end
M.remove_current_sesion = function()
  vim.cmd([[SessionManager delete_session]])
  Ty.NOTIFY("Session removed")
end
M.list_all_session = function()
  vim.cmd([[SessionManager load_session]])
end

---@param dir string 'next' or 'prev
M.jump_to_todo = function(dir)
  if not require('ty.core.utils').has_plugin('todo-comments.nvim') then
    return
  end
  require('todo-comments')['jump_' .. dir]()
end

M.toggle_qf = function()
  if utils.has_plugin('trouble.nvim') then
    if require('trouble').is_open() then
      require('trouble').close()
      return
    end
  end
  local buffers = vim.api.nvim_list_bufs()
  local bufFound = false
  for _, buffer in ipairs(buffers) do
    -- local bufferType = vim.api.nvim_buf_get_option(buffer, 'buftype')
    local bufferType = vim.api.nvim_get_option_value("buftype", {
      buf = buffer,
    })
    if bufferType == 'quickfix' then
      bufFound = true
      break
    end
  end
  if not bufFound then
    vim.api.nvim_command('botright copen 10')
  else
    vim.api.nvim_command('cclose')
  end
end

return M
