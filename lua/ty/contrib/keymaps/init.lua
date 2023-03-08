local M = {}

M.init = function()
  local autocmd = require('ty.core.autocmd')
  require('ty.contrib.keymaps.basic')

  local au = autocmd.with_group('attach_binding')
  autocmd.on_attach(require('ty.contrib.keymaps.attach.lsp'), au.group)

  require('ty.contrib.keymaps.attach.git_blame')(au)
  require('ty.contrib.keymaps.attach.npm')(au)
  require('ty.contrib.keymaps.attach.jest')(au)

  if require('ty.core.utils').has_plugin('which-key.nvim') then require('ty.contrib.keymaps.whichkey').init() end
end

return M
