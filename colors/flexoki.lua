local load = function()
  local flexoki = require('flexoki')
  flexoki.colorscheme({ variant = vim.o.background or 'dark' })
end

load()
