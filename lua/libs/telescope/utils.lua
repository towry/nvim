local M = {}


---@param fallback? boolean
function M.get_cwd_relative_to_buf(bufnr, level_number, fallback)
  local Path = require('libs.runtime.path')
  local buftype = vim.api.nvim_get_option_value('buftype', {
    buf = bufnr,
  })

  if buftype == '' and level_number > 0 and level_number < 10 then
    return Path.level_up_by(vim.api.nvim_buf_get_name(bufnr), level_number)
  end
  if fallback == false then return nil end
  return require('libs.runtime.utils').get_root()
end

return M
