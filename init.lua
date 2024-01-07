if vim.loader then
  vim.loader.enable()
end

if not vim.g.vscode then
  pcall(require, 'settings_env')
  -- fix background flickering.
  -- vim.cmd.colorscheme('vim')
else
  require('user.vscode.startup')
end
require('user.config').setup()
if vim.g.vscode then
  require('user.vscode.setup')
end
