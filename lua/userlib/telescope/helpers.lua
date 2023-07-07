local M = {}


---@param fallback? boolean
function M.get_cwd_relative_to_buf(bufnr, level_number, fallback)
  local Path = require('userlib.runtime.path')
  local buftype = vim.api.nvim_get_option_value('buftype', {
    buf = bufnr,
  })

  if buftype == '' and level_number > 0 and level_number < 10 then
    return Path.level_up_by(vim.api.nvim_buf_get_name(bufnr), level_number)
  end
  if fallback == false then return nil end

  --- NOTE: if current buffer has binding for numbers, the v:count may not be working correctly.
  if buftype ~= '' and level_number ~= 0 then
    -- use loop cwd instead of pattern matched root.
    -- User may start vim inside a subfolde of workspace/git folder, the root pattern returns the workspace/git root instead of
    -- the start pwd.
    return vim.uv.cwd()
  end

  return require('userlib.runtime.utils').get_root()
end

return M
