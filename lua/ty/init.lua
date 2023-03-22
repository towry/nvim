pcall(require, 'impatient')
require('ty.core.globals')

local M = {}
local _inited = false
local startup_repos = require('ty.startup.repos')

local function resize_kitty()
  local kitty_aug = vim.api.nvim_create_augroup('kitty_aug', { clear = true })
  local resized = false
  vim.api.nvim_create_autocmd('User', {
    group = kitty_aug,
    pattern = 'DashboardDismiss',
    callback = function()
      vim.schedule(function()
        resized = true
        vim.cmd(':silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=0 margin=0')
      end)
    end,
  })
  vim.api.nvim_create_autocmd('UILeave', {
    group = kitty_aug,
    pattern = '*',
    callback = function()
      if not resized then return end
      vim.cmd(':silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=8 margin=0')
    end,
  })
end

function M.setup()
  if _inited then return end
  _inited = true

  vim.g.mapleader = ' '
  vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
  vim.g.maplocalleader = ','

  resize_kitty()
  require('ty.core.options').setup()
  require('ty.core.pack').setup(startup_repos.repos, startup_repos.initd)
end

return M
