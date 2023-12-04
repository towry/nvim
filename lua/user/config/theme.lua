local M = {}
local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end

function M.custom_theme_wildcharm()
  --- custom wildcharm theme.
  vim.cmd([[hi! Visual guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE]])
end

function M.custom_theme_default()
  local extend_hl = require('userlib.runtime.utils').extend_hl

  --- mini MiniCursorword
  extend_hl({ 'MiniCursorword', 'Normal' }, {
    italic = true,
  })
  extend_hl({ 'MiniCursorwordCurrent', 'Normal' }, {
    underline = false,
    bold = true,
  })
  --- git
  hi('diffAdded', { link = 'DiffAdd' })
  hi('diffRemoved', { link = 'DiffDelete' })
  hi('diffChanged', { link = 'DiffChange' })
  extend_hl({ 'diffFile', 'Type', }, {
    bold = true
  })
  extend_hl({ 'diffOldFile', 'DiffAdd' }, {
    bg = 'NONE'
  })
  extend_hl({ 'diffNewFile', 'DiffDelete' }, {
    bg = 'NONE'
  })
  --- telescope
  hi('TelescopeMatching', { link = 'Visual' })
end

local is_setup_theme_done = false
function M.setup_theme()
  if is_setup_theme_done then return end
  local ok = vim.cfg.ui__theme_name == 'default' and true or pcall(vim.cmd, 'colorscheme ' .. vim.cfg.ui__theme_name)
  if ok then
    is_setup_theme_done = true
  else
    return
  end
  if type(M['custom_theme_' .. vim.cfg.ui__theme_name]) == 'function' then
    vim.schedule(M['custom_theme_' .. vim.cfg.ui__theme_name])
  end
end

M.setup = function()
  if vim.cfg.runtime__starts_in_buffer then M.setup_theme() end
end

return M
