if vim.loader then
  vim.loader.enable()
  vim.schedule(function()
    vim.notify("nvim cache is enabled")
  end)
end
vim.g.profile_loaders = true
require("ty").setup()
