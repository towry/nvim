if vim.loader then
  vim.loader.enable()
end

require('user.config').setup()
pcall(require, 'settings_env')
