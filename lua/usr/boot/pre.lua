do -- Required by lazy.nvim
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ','
end

pcall(require, 'nix-env')
pcall(require, 'settings_env')
require('usr.core.globals')
