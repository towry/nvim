if vim.loader then
  vim.loader.disable()
end

require('user.config').setup()
