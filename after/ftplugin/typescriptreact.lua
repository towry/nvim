vim.treesitter.language.register('tsx', 'typescriptreact')

--- bugfix for ts
vim.g.treesitter_start = vim.g.treesitter_start or vim.treesitter.start
vim.treesitter.start = function(...)
  vim.g.treesitter_start(...)
  vim.treesitter.language.register('tsx', 'typescriptreact')
end
