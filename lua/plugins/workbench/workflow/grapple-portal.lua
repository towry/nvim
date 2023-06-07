return {
  {
    'cbochs/portal.nvim',
    cmd = { 'Portal' },
    keys = {
      {
        '<M-o>',
        function()
          local builtins = require('portal.builtin')
          local opts = {
            direction = 'backward',
            max_results = 2,
          }

          local jumplist = builtins.jumplist.query(opts)
          -- local harpoon = builtins.harpoon.query(opts)
          local grapples = builtins.grapple.query(opts)

          require('portal').tunnel({ jumplist, grapples })
        end,
        desc = 'Portal jump backward',
      },
      {
        '<M-i>',
        function()
          local builtins = require('portal.builtin')
          local opts = {
            direction = 'forward',
            max_results = 2,
          }

          local jumplist = builtins.jumplist.query(opts)
          -- local harpoon = builtins.harpoon.query(opts)
          local grapples = builtins.grapple.query(opts)

          require('portal').tunnel({ jumplist, grapples })
        end,
        desc = 'Portal jump forward',
      }
    },
    dependencies = {
      'cbochs/grapple.nvim',
    },
    config = function()
      -- local nvim_set_hl = vim.api.nvim_set_hl
      require('portal').setup({
        log_level = 'error',
        window_options = {
          relative = "cursor",
          width = 40,
          height = 2,
          col = 1,
          focusable = false,
          border = "rounded",
          noautocmd = true,
        }
      })

      -- FIXME: colors.
      -- nvim_set_hl(0, 'PortalBorderForward', { fg = colors.portal_border_forward })
      -- nvim_set_hl(0, 'PortalBorderNone', { fg = colors.portal_border_none })
    end,
  },
  {
    'cbochs/grapple.nvim',
    keys = {
      { '<leader>bg', '<cmd>GrappleToggle<cr>', desc = 'Toggle grapple' },
      { '<leader>bp', '<cmd>GrapplePopup<cr>',  desc = 'Popup grapple' },
      { '<leader>bc', '<cmd>GrappleCycle<cr>',  desc = 'Cycle grapple' },
    },
    cmd = { 'GrappleToggle', 'GrapplePopup', 'GrappleCycle' },
    opts = {
      log_level = 'error',
      scope = 'git',
      integrations = {
        resession = false,
      },
    }
  }
}
