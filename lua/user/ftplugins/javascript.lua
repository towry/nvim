local M = {}

M.attach = function()
  if vim.b.is_big_file or vim.g.vscode then
    return
  end
  require('userlib.keymaps.neotest').attach()
  require('userlib.keymaps.dap').attach()
  if package.loaded['typescript-tools'] then
    require('typescript-tools.user_commands').setup_user_commands()
  end
end

return M
