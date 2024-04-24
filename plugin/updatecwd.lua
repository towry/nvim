local au = require('userlib.runtime.au')

au.on_verylazy(function()
  local cwd = vim.cfg.runtime__starts_cwd
  local utils = require('userlib.runtime.utils')

  local newcwd = utils.get_root({
    only_pattern = true,
    pattern_start_path = cwd,
  })

  if newcwd ~= cwd then
    vim.cfg.runtime__starts_cwd = newcwd
    vim.notify('Cwd changed: ' .. newcwd, vim.log.levels.INFO)
  end
end)
