local dislike = require('core.spec').dislike
local not_inside = require('core.spec').not_inside

return {
  dislike('folke/noice.nvim'),
  dislike('rcarriga/nvim-notify'),
  { import = 'lazyvim.plugins.extras.ui.treesitter-context' },
  {
    'j-hui/fidget.nvim',
    event = { 'VeryLazy' },
    enabled = not_inside.git,
    opts = {
      progress = {
        ignore = {
          'null-ls',
          'tailwindcss',
          'jsonls',
          -- 'copilot',
        },
      },
      notification = {
        override_vim_notify = true,
        window = {
          winblend = 30,
          normal_hl = 'NormalFloat',
          max_width = 50,
          border = 'solid',
          -- align = 'top',
        },
      },
    },
    init = function()
      require('core.vi').command('FidgetHistory', function()
        require('fidget.notification').show_history()
      end, {
        desc = 'Show fidget notification history',
      })
    end,
  },
}
