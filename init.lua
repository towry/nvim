do
  if vim.fn.has('nvim-0.10') == 0 then
    print('nvim >= 0.10 is required')
    return
  end
end
pcall(require, 'settings_env')
if vim.g.vscode then
  require('user.vscode.startup')
end
require('user.config').setup()
if vim.g.vscode then
  require('user.vscode.setup')
end
