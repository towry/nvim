if vim.loader then
  vim.loader.enable()
end

-- fix default theme loadinng flickering issue.
vim.cmd.colorscheme('vim')

pcall(require, 'settings_env')
require('user.config').setup()
