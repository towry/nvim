local load = function()
  local style = vim.o.background == 'light' and vim.g.nightfox_day or vim.g.nightfox_night
  require('nightfox.config').set_fox(style)
  require('nightfox').load()
  --- must set after load
  --- to make bg change work
  vim.g.colors_name = 'minifox'
end

load()
