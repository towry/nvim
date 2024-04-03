local load = function()
  local flexoki = require('flexoki')
  flexoki.colorscheme({ variant = vim.o.background or 'dark' })
end

-- FIXME: this autocmd will be called everytime other colorscheme changed.

vim.api.nvim_create_augroup('load_flexoki', { clear = true })
vim.api.nvim_create_autocmd('OptionSet', {
  group = 'load_flexoki',
  pattern = 'background',
  callback = load,
})
load()
