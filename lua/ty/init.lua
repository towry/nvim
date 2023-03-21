local M = {}
local _inited = false

local function resize_kitty()
  local kitty_aug = vim.api.nvim_create_augroup('kitty_aug', { clear = true })
  vim.api.nvim_create_autocmd('UIEnter', {
    group = kitty_aug,
    pattern = '*',
    callback = function()
      vim.defer_fn(function() vim.cmd(':silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=0 margin=0') end, 1)
    end,
  })
  vim.api.nvim_create_autocmd('UILeave', {
    group = kitty_aug,
    pattern = '*',
    command = ':silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=8 margin=0',
  })
end

function M.setup()
  if _inited then return end
  _inited = true

  vim.g.mapleader = ' '
  vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
  vim.g.maplocalleader = ','

  resize_kitty()

  require('ty.core.globals')
  require('ty.core.options').setup()
  pcall(require, 'settings_env') -- load env settings
  require('ty.core.pack'):setup()
end

return M
