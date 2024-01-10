_G.setup_minifox = function()
  local style = vim.o.background == 'light' and 'dayfox' or 'nightfox'
  require('nightfox.config').set_fox(style)
  require('nightfox').load()
end

vim.api.nvim_create_augroup('nightfox_color', { clear = true })
vim.api.nvim_create_autocmd({ 'OptionSet' }, {
  group = 'nightfox_color',
  callback = vim.schedule_wrap(function(ctx)
    local match = ctx.match
    if match == 'background' then
      _G.setup_minifox()
    end
  end),
})

_G.setup_minifox()
