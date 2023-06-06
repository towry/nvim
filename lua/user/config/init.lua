local M = {}

function M.setup()
  require('user.config.custom').setup()
  require('user.config.options').setup()
  require('plugins').setup()
  require('user.config.autocmd').setup({
    resize_kitty = true
  })
end

return M
