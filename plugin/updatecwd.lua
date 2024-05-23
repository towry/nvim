do
  if vim.g.updatecwd_loaded == 1 or not vim.cfg then
    return
  end
  vim.g.updatecwd_loaded = 1
end
local cwd = vim.cfg.runtime__starts_cwd
local utils = require('userlib.runtime.utils')

local newcwd = utils.get_root({
  only_pattern = true,
  pattern_start_path = cwd,
})

if newcwd ~= cwd then
  if vim.cfg.runtime__starts_cwd == vim.uv.cwd() then
    vim.cmd('noau cd ' .. newcwd)
  end
  vim.cfg.runtime__starts_cwd = newcwd
  vim.schedule(function()
    vim.notify('Cwd changed: ' .. newcwd, vim.log.levels.INFO)
  end)
end
