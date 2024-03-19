local group = vim.api.nvim_create_augroup('github_dark_light', { clear = true })
local current = nil

local load_github = function()
  local variant = vim.g.github_variant and vim.g.github_variant ~= '' and vim.g.github_variant or nil
  local theme = 'github_' .. vim.o.background .. (variant and '_' .. variant or '')
  if current == theme then
    return
  end
  current = theme
  require('github-theme.config').set_theme(theme)
  require('github-theme').load()
end

vim.api.nvim_create_autocmd('OptionSet', {
  pattern = 'background',
  group = group,
  callback = load_github,
})

load_github()
