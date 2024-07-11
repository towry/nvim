return {
  --- disabled
  { 'folke/noice.nvim', enabled = false },
  { 'rcarriga/nvim-notify', enabled = false },
  ---
  { import = 'lazyvim.plugins.extras.ui.treesitter-context' },
  {
    'nvimdev/dashboard-nvim',
    opts = {
      config = {
        week_header = {
          enable = true,
        },
      },
    },
  },
  {
    'j-hui/fidget.nvim',
    event = { 'VeryLazy' },
    enabled = not vim.g.cfg_inside.git,
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
      require('v').nvim_command('FidgetHistory', function()
        require('fidget.notification').show_history()
      end, {
        desc = 'Show fidget notification history',
      })
    end,
  },
}
