-- env requirements
pcall(require, 'nix-env')
pcall(require, 'settings_env')
-- dispatch to LazyVim
require('config.lazy')
