local M = {}

M.attach = function()
  if vim.b.is_big_file then
    return
  end
  require('userlib.keymaps.neotest').attach()
  require('userlib.keymaps.dap').attach()
  require('typescript-tools.user_commands').setup_user_commands()
end

return M
