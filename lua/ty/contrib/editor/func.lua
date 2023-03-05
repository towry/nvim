local M = {}

M.save_current_session = function()
  vim.cmd([[SessionManager save_current_session<CR>]])
end
M.load_last_session = function()
  vim.cmd([[SessionManager load_last_session<CR>]])
end
M.remove_current_sesion = function()
  vim.cmd([[SessionManager delete_session<CR>]])
end
M.list_all_session = function()
  vim.cmd([[SessionManager load_session<CR>]])
end

---@param dir string 'next' or 'prev
M.jump_to_todo = function(dir)
  if not require('ty.core.utils').has_plugin('todo-comments.nvim') then
    return
  end
  require('todo-comments')['jump_' .. dir]()
end

return M

