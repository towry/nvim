local function setup_legendary()
  local has_legendary = require('libs.runtime.utils').has_plugin('legendary.nvim')
  if not has_legendary then return end
  local legendary = require('legendary')

  legendary.func({
    function() require('telescope').extensions.yank_history.yank_history({}) end,
    description = 'Paste from yanky',
  })
  legendary.keymaps({
    { '<Plug>(YankyCycleForward)',  description = 'Yanky/paste cycle forward ' },
    { '<Plug>(YankyCycleBackward)', description = 'Ynky/paste cycle backward ' },
  })
end

return {
  -- better yank
  'gbprod/yanky.nvim',
  keys = {
    {
      'y', '<Plug>(YankyYank)', mode = { 'n', 'x', }, desc = 'Yanky yank',
    },
    {
      'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x', }, desc = 'Yanky put after',
    },
    {
      'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x', }, desc = 'Yanky put before',
    },
    {
      'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x', }, desc = 'Yanky gput after',
    },
    {
      'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x', }, desc = 'Yanky gput before',
    },
  },
  config = function()
    require('yanky').setup({
      highlight = {
        timer = 150,
      },
      ring = {
        history_length = 30,
        storage = 'shada',
      },
    })
  end,

  init = function()
    local au = require('libs.runtime.au')
    au.define_autocmds({
      {
        "User",
        {
          group = "setup_yanky_lg",
          pattern = au.user_autocmds.LegendaryConfigDone,
          once = true,
          callback = function()
            setup_legendary()
          end,
        }
      }
    })
  end,
}
