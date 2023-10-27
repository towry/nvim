local M = {}

M.attach = function()
  require('userlib.keymaps.neotest').attach()
  require('userlib.keymaps.dap').attach()
end

return M
