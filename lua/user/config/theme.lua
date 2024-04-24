local M = {}
local hi = function(name, data)
  vim.api.nvim_set_hl(0, name, data)
end

local hi_fzflua = function()
  --- fzf lua
  hi('FzfLuaNormal', { link = 'NormalFloat' })
  hi('FzfLuaBorder', { link = 'FloatBorder' })
  --- builtin preview main
  hi('FzfLuaPreviewNormal', { link = 'Normal' })
end
local hi_minicursorword = function()
  local extend_hl = require('userlib.runtime.utils').extend_hl

  --- do not change text highlight in the git diff
  --- mini MiniCursorword
  extend_hl({ 'MiniCursorword', 'Normal' }, {
    italic = true,
    bold = true,
    underline = false,
    bg = 'NONE',
    fg = 'NONE',
  })
  extend_hl({ 'MiniCursorwordCurrent', 'Normal' }, {
    underline = false,
    bold = true,
    bg = 'NONE',
    fg = 'NONE',
  })
end
local hi_coc = function()
  local extend_hl = require('userlib.runtime.utils').extend_hl
  hi('CocPumMenu', { link = 'PmenuSel' })
end

function M.custom_theme_slate()
  M.custom_theme_default()
  hi_coc()
end

function M.custom_theme_default()
  local extend_hl = require('userlib.runtime.utils').extend_hl

  hi_minicursorword()
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
  extend_hl({ 'DiagnosticUnnecessary', 'Comment' }, {
    undercurl = true,
  })
  --- telescope
  -- hi('TelescopeMatching', { link = 'Visual' })
  hi('TelescopeNormal', { link = 'NormalFloat' })
  hi('TelescopeBorder', { link = 'FloatBorder' })
  -- aerial
  hi('AerialPrivate', { italic = true })
  hi_fzflua()
end

function M.custom_theme_gruvbox()
  M.custom_theme_default()
end

function M.custom_theme_kanagawa()
  M.custom_theme_default()
end

local function update_custom_theme()
  M.custom_theme_default()
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
  M.setup_theme()
end

M.toggleterm = function()
  if vim.cfg.ui__theme_name == 'rose-pine' then
    return require('rose-pine.plugins.toggleterm')
  end
  return {}
end

return M
