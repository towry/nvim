local M = {}

local pre_hook_records = {}

--- Use this to dynamic register to legendary.
--- callback should return false if it does want to run again on next pre hook event.
---@param name string
---@param callback function
function M.pre_hook(name, callback)
  if type(name) ~= 'string' then
    error('register legendary: first argument must be an unique name')
  end
  if pre_hook_records[name] then
    return
  end
  local autocmd_id

  if vim.v.vim_did_enter then
    vim.schedule(function()
      callback(require('legendary'))
    end)
    return
  end

  autocmd_id = vim.api.nvim_create_autocmd('User', {
    pattern = 'LegendaryUiPre',
    callback = function()
      local result = callback(require('legendary'))
      if result ~= false then
        pre_hook_records[name] = true
        vim.api.nvim_del_autocmd(autocmd_id)
      end
    end,
  })
end

M.register = M.pre_hook

return M
