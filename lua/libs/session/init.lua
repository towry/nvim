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

return M
