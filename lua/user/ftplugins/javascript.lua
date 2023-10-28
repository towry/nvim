local M = {}

M.attach = function()
  require('userlib.keymaps.neotest').attach()
  require('userlib.keymaps.dap').attach()
  require('userlib.keymaps.overseer').attach()
end

return M
