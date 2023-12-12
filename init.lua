if vim.loader then
  vim.loader.enable()
end

if not vim.g.vscode then
  -- fix default theme loadinng flickering issue.
  vim.cmd.colorscheme('vim')
  pcall(require, 'settings_env')
else
  require('user.vscode.startup')
end
require('user.config').setup()
if vim.g.vscode then
  require('user.vscode.setup')
end
