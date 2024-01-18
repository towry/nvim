local M = {}
local hi = function(name, data)
  vim.api.nvim_set_hl(0, name, data)
end

function M.custom_theme_wildcharm()
  --- custom wildcharm theme.
  vim.cmd([[hi! Visual guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE]])
end

function M.custom_theme_default()
  local extend_hl = require('userlib.runtime.utils').extend_hl

  --- do not change text highlight in the git diff
  --- mini MiniCursorword
  extend_hl({ 'MiniCursorword', 'Normal' }, {
    italic = true,
    bold = true,
    bg = 'NONE',
  })
  extend_hl({ 'MiniCursorwordCurrent', 'Normal' }, {
    underline = false,
    bold = true,
    bg = 'NONE',
    fg = 'NONE',
  })
  --- git
  hi('diffAdded', { link = 'DiffAdd' })
  hi('diffRemoved', { link = 'DiffDelete' })
  hi('diffChanged', { link = 'DiffChange' })
  extend_hl({ 'diffFile', 'Type' }, {
    bold = true,
  })
  extend_hl({ 'diffOldFile', 'DiffAdd' }, {
    bg = 'NONE',
  })
  extend_hl({ 'diffNewFile', 'DiffDelete' }, {
    bg = 'NONE',
  })
  --- telescope
  -- hi('TelescopeMatching', { link = 'Visual' })
  -- aerial
  hi('AerialPrivate', { italic = true })
  --- fzf lua
  hi('FzfLuaNormal', { link = 'Normal' })
  hi('FzfLuaBorder', { link = 'LineNr' })
  --- builtin preview main
  hi('FzfLuaPreviewNormal', { link = 'Normal' })
end

function M.custom_theme_modus()
  M.custom_theme_default()
  -- hi('LineNr', { link = 'Normal' })
  -- hi('FoldColumn', { link = 'Normal' })
end

function M.custom_theme_kanagawa()
  M.custom_theme_default()
end

function M.custom_theme_everforest()
  M.custom_theme_default()
end

M['custom_theme_rose-pine'] = function()
  -- M.custom_theme_default()
end

local function update_custom_theme()
  if type(M['custom_theme_' .. vim.cfg.ui__theme_name]) == 'function' then
    vim.schedule(M['custom_theme_' .. vim.cfg.ui__theme_name])
  end
end
local is_setup_theme_done = false
function M.setup_theme()
  if is_setup_theme_done then
    return
  end
  local ok = vim.cfg.ui__theme_name == 'default' and true or pcall(vim.cmd, 'colorscheme ' .. vim.cfg.ui__theme_name)
  if ok then
    is_setup_theme_done = true
  else
    return
  end

  update_custom_theme()

  vim.api.nvim_create_augroup('update_custom_theme', { clear = true })
  vim.api.nvim_create_autocmd('OptionSet', {
    group = 'update_custom_theme',
    pattern = 'background',
    callback = update_custom_theme,
  })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = 'update_custom_theme',
    pattern = '*',
    callback = update_custom_theme,
  })
end

M.setup = function()
  if vim.cfg.runtime__starts_in_buffer then
    M.setup_theme()
  end
end

M.toggleterm = function()
  if vim.cfg.ui__theme_name == 'rose-pine' then
    return require('rose-pine.plugins.toggleterm')
  end
  return {}
end

return M
