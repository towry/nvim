if vim.loader then
  vim.loader.enable()
  vim.schedule(function() vim.notify('nvim cache is enabled') end)
  vim.g.profile_loaders = true
end

require('ty').setup()
