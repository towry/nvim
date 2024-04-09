pcall(require, 'settings_env')
vim.cmd.colorscheme('vim')
if vim.g.vscode then
  require('user.vscode.startup')
end
require('user.config').setup()
if vim.g.vscode then
  require('user.vscode.setup')
end
