local M = {}

function M.setup()
  require('libs.runtime.globals')
  require('user.config.custom').setup()
  require('user.config.options').setup()
  require('user.config.keymaps').setup()

  require('user.config.lazy').setup({
    spec = require('user.config.plugs'),
  })
  pcall(vim.cmd, 'colorscheme ' .. vim.cfg.ui__theme_name)

  require('user.config.autocmd').setup({
    resize_kitty = true
  })
end

return M
