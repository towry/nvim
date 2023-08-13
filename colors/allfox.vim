lua << EOF
local update = function()
  local theme_name = vim.o.background == 'dark' and 'nightfox' or 'dayfox'
  if vim.g.colors_name then
    vim.cmd('highlight clear')
  end
  vim.g.colors_name = theme_name
  require("nightfox.config").set_fox(theme_name)
  require("nightfox").load()
end

vim.api.nvim_create_augroup('allfox_auto_dark', { clear = true })
vim.api.nvim_create_autocmd('OptionSet', {
  pattern = 'background',
  callback = update,
})
update()
EOF
