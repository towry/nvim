local M = {}

local function setup_legendary()
  local has_legendary = require('ty.core.utils').has_plugin('legendary.nvim')
  if not has_legendary then return end
  local legendary = require('legendary')

  legendary.func({
    function() require('telescope').extensions.yank_history.yank_history({}) end,
    description = 'Paste from yanky',
  })
  legendary.keymaps({
    { '<Plug>(YankyCycleForward)', description = 'Yanky/paste cycle forward ' },
    { '<Plug>(YankyCycleBackward)', description = 'Ynky/paste cycle backward ' },
  })
end

function M.setup()
  require('yanky').setup({
    highlight = {
      timer = 150,
    },
    ring = {
      history_length = 30,
      storage = 'shada',
    },
  })

  vim.keymap.set({ 'n', 'x' }, 'y', '<Plug>(YankyYank)')
  vim.keymap.set({ 'n' }, 'p', '<Plug>(YankyPutAfter)')
  vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
  vim.keymap.set({ 'n', 'x' }, 'gp', '<Plug>(YankyGPutAfter)')
  vim.keymap.set({ 'n', 'x' }, 'gP', '<Plug>(YankyGPutBefore)')

  setup_legendary()
end

return M
