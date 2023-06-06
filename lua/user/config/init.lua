local M = {}

function M.setup()
  require('user.config.custom').setup()
  require('user.config.options').setup()
  require('user.config.lazy').setup()
  require('user.config.autocmd').setup({
    resize_kitty = true
  })
end

return M
