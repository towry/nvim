if vim.loader then
  vim.loader.enable()
end

pcall(require, 'settings_env')
require('user.config').setup()
