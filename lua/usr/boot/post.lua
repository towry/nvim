-- require some lazy setup, like lazy options, autocmds, commands etc
do -- colorscheme
  local internal = require('internal')
  vim.cmd('colorscheme ' .. internal.config.colorscheme)
end
