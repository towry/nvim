local current_bg = nil
local setup_minifox = function()
  if current_bg == vim.o.background then
    return
  end
  current_bg = vim.o.background
  local style = vim.o.background == 'light' and vim.g.nightfox_day or vim.g.nightfox_night
  require('nightfox.config').set_fox(style)
  require('nightfox').load()
end

setup_minifox()
