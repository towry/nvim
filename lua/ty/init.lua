local M = {}
local _inited = false
local autocmd = require('ty.core.autocmd')

local function setup_later_modules()
  require('ty.core.pack'):startup() -- start loading modules.
end
local function resize_kitty()
  local kitty_aug = vim.api.nvim_create_augroup("kitty_aug", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = kitty_aug,
    pattern = "*",
    command = ":silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=0 margin=0"
  })
  vim.api.nvim_create_autocmd("VimLeave", {
    group = kitty_aug,
    pattern = "*",
    command = ":silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=8 margin=0"
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
  if vim.fn.argc( -1) == 0 then
    autocmd.on_very_lazy(setup_later_modules)
    require('ty.core.pack'):setup()
  else
    require('ty.core.pack'):setup()
    setup_later_modules()
  end
end

return M
