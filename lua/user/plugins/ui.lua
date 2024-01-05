local plug = require('userlib.runtime.pack').plug

plug({
  {
    enabled = false,
    'rcarriga/nvim-notify',
    event = 'User LazyUIEnter',
    config = function()
      require('notify').setup({
        timeout = 3000,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        on_open = function(win)
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, { border = vim.cfg.ui__float_border })
          end
        end,
        render = function(...)
          -- local notif = select(2, ...)
          local style = 'default'
          -- local style = notif.title[1] == '' and 'default' or 'default'
          require('notify.render')[style](...)
        end,
        top_down = false,
      })

      local banned_msgs = {
        'No information available',
        'LSP[tsserver] Inlay Hints request failed. File not opened in the editor.',
        'LSP[tsserver] Inlay Hints request failed. Requires TypeScript 4.4+.',
      }
      vim.notify = function(msg, ...)
        -- check banned_msgs contains msg with reg match
        if vim.tbl_contains(banned_msgs, msg) then
          return
        end

        require('notify')(msg, ...)
      end
    end,
  },

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
    enabled = false,
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
          winblend = 150,
          max_width = 200,
          -- border = "rounded"
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
    enabled = true,
    config = function()
      require('mini.notify').setup({
        lsp_progress = {
          duration_last = 3000,
        },
        window = {
          config = {
            -- solid, shadow, rounded
            border = 'solid',
          },
          winblend = 50,
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
    dev = false,
    ft = 'qf',
    keys = {
      {
        '<A-q>',
        function()
          local current_win_is_qf = vim.bo.filetype == 'qf'
          if current_win_is_qf then
            vim.cmd('wincmd p')
          else
            -- focus on qf window
            vim.cmd('copen')
          end
        end,
        desc = 'Switch between quickfix window and previous window',
      },
      {
        '<leader>tq',
        '<cmd>lua require("userlib.runtime.qf").toggle_qf()<cr>',
        desc = 'Toggle quickfix',
      },
      {
        '<leader>tl',
        '<cmd>lua require("userlib.runtime.qf").toggle_loc()<cr>',
        desc = 'Toggle loclist',
      },
    },
    opts = {
      preview = {
        winblend = 0,
        show_scroll_bar = false,
        show_title = true,
      },
    },
  },
})
