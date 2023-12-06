if vim.loader then
  vim.loader.enable()
end

pcall(require, 'settings_env')
vim.cmd('colorscheme vim')
require('user.config').setup()
