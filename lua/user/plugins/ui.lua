local plug = require('userlib.runtime.pack').plug

plug({
  {
    enabled = false,
    'echasnovski/mini.animate',
    event = vim.cfg.runtime__starts_in_buffer and { 'User LazyUIEnter' } or { 'User DoEnterDashboard' },
    opts = function()
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs({ 'Up', 'Down' }) do
        local key = '<ScrollWheel' .. scroll .. '>'
        vim.keymap.set({ '', 'i' }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      local animate = require('mini.animate')
      return {
        resize = {
          timing = animate.gen_timing.linear({ duration = 100, unit = 'total' }),
        },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 150, unit = 'total' }),
          subscroll = animate.gen_subscroll.equal({
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          }),
        },
      }
    end,
  },

  {
    'j-hui/fidget.nvim',
    event = { 'User LazyUIEnter', 'LspAttach' },
    enabled = not vim.cfg.runtime__starts_as_gittool,
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
      vim.api.nvim_create_user_command('FidgetHistory', function()
        require('fidget.notification').show_history()
      end, {
        desc = 'Show fidget notification history',
      })
    end,
  },

  {
    'echasnovski/mini.notify',
    event = { 'User LazyUIEnter', 'LspAttach' },
    enabled = false,
    config = function()
      local win_config = function()
        local has_statusline = vim.o.laststatus > 0
        local bottom_space = vim.o.cmdheight + (has_statusline and 1 or 0)
        return { border = 'single', anchor = 'SE', col = vim.o.columns, row = vim.o.lines - bottom_space }
      end
      require('mini.notify').setup({
        lsp_progress = {
          duration_last = 3000,
        },
        window = {
          config = win_config,
          winblend = 20,
        },
      })
      local opts = { ERROR = { duration = 10000 } }
      vim.notify = require('mini.notify').make_notify(opts)
      vim.api.nvim_create_user_command('Notifyhistory', function()
        require('mini.notify').show_history()
      end, {
        desc = 'Show mini notify history',
      })
    end,
  },

  {
    'pze/nvim-bqf',
    -- 'kevinhwang91/nvim-bqf',
    -- version = '*',
    dev = false,
    ft = 'qf',
    enabled = false,
    opts = {
      preview = {
        winblend = 10,
        show_scroll_bar = false,
        show_title = true,
      },
    },
  },

  {
    'folke/trouble.nvim',
    ft = 'qf',
    enabled = true,
    cmd = {
      'Trouble',
      'TroubleClose',
      'TroubleToggle',
      'TroubleRefresh',
    },
    opts = {},
  },
})
