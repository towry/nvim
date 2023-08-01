if vim.loader then
  vim.loader.enable()
  local is_ok, lazy_cache = pcall(require, 'lazy.core.cache')
  if is_ok then
    package.loaded["lazy.core.cache"] = vim.loader
    lazy_cache.enable()
  end
end

require('user.config').setup()
