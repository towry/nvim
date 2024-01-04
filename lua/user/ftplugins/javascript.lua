local M = {}

M.attach = function()
  if vim.b.is_big_file then
    return
  end
  require('userlib.keymaps.neotest').attach()
  require('userlib.keymaps.dap').attach()
end

return M
