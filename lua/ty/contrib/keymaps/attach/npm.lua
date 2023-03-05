local function bind_npm_keys(bufnr)
  local keymap = require('ty.core.keymap')
  local n, cmd = keymap.n, keymap.cmd

  if not require('ty.core.utils').has_plugin('package-info.nvim') then return end

  local prefix = "lua require('package-info')."
  n('<localleader>nc', 'NPM: Change package version', cmd(prefix .. 'change_version()', { buffer = bufnr }))
  n('<localleader>nh', 'NPM: Hide package info', cmd(prefix .. 'hide()', { buffer = bufnr }))
  n('<localleader>ni', 'NPM: Install new package', cmd(prefix .. 'install()', { buffer = bufnr }))
  n('<localleader>nr', 'NPM: Reinstall dependencies', cmd(prefix .. 'reinstall()', { buffer = bufnr }))
  n('<localleader>ns', 'NPM: Show package info', cmd(prefix .. 'show()', { buffer = bufnr }))
  n('<localleader>nu', 'NPM: Update package', cmd(prefix .. 'update()', { buffer = bufnr }))
  n('<localleader>nd', 'NPM: Delete package', cmd(prefix .. 'delete()', { buffer = bufnr }))
end

return function(au)
  au:create('BufEnter', {
    pattern = { 'package.json' },
    callback = function(ctx) bind_npm_keys(ctx.bufnr) end,
  })
end
