local M = {}
local _inited = false

local function setup_later_modules() require('ty.core.pack'):startup() end

function M.setup()
  if _inited then return end
  _inited = true

  vim.g.mapleader = ' '
  vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
  vim.g.maplocalleader = ','

  require('ty.core.globals')
  require('ty.core.options').setup()
  if vim.fn.argc(-1) == 0 then
    require('ty.core.autocmd').on_lazy_done(setup_later_modules)
  else
    vim.schedule(setup_later_modules)
  end
  require('ty.core.pack'):setup()
end

return M
