local au = require('userlib.runtime.au')
local plug = require('userlib.runtime.pack').plug

-- start screen
return plug({
  -- enable mini.starter
  {
    'echasnovski/mini.starter',
    enabled = true,
    version = false, -- wait till new 0.7.0 release to put it back on semver
    opts = function()
      local pad = string.rep(' ', 0)
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require('mini.starter')
      --stylua: ignore
      local config = {
        silent = true,
        evaluate_single = false,
        items = {
          starter.sections.recent_files(9, true, false),
          --- last.
          new_section("Git Branchs", "Telescope git_branches show_remote_tracking_branches=false", "Built-in"),
          new_section("Lazy", "Lazy", "Built-in"),
          new_section("Quit current", "q", "Built-in"),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(pad .. "⦿ ", false),
          starter.gen_hook.aligning("left", "top"),
        },
        -- remove number from query since we need it as v:count
        query_updaters = 'abcdefghijklmnopqrstuvwxyz.'
      }
      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      local show_lazy_cb = false
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        show_lazy_cb = true
      end
      local starter = require('mini.starter')
      starter.setup(config)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniStarterOpened',
        callback = function(ctx)
          vim.b.minianimate_disable = true
          if show_lazy_cb then
            require('lazy').show()
            show_lazy_cb = false
          end
          local bufnr = ctx.buf
          if not bufnr then return end
          vim.keymap.set(
            'n',
            ']',
            [[<cmd>lua MiniStarter.update_current_item('prev')<CR>]],
            { buffer = bufnr, nowait = true, silent = true }
          )
          vim.keymap.set(
            'n',
            '[',
            [[<cmd>lua MiniStarter.update_current_item('next')<CR>]],
            { buffer = bufnr, nowait = true, silent = true }
          )

          au.define_autocmd({ 'VimResized', 'WinResized' }, {
            group = '_refresh_starter',
            buffer = bufnr,
            command = 'lua MiniStarter.refresh(1)',
          })
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        once = true,
        callback = function()
          local stats = require('lazy').stats()

          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          starter.config.footer = table.concat({
            ' ' .. stats.count,
            ' · ',
            ' ' .. ms .. 'ms',
          }, ' ')
          pcall(starter.refresh)
        end,
      })
    end,
    init = function()
      -- listen enter dashboard event.
      au.define_autocmds({
        {
          'User',
          {
            group = '_plugin_enter_dashboard',
            pattern = au.user_autocmds.DoEnterDashboard,
            callback = function(ctx)
              local data = ctx.data or {}
              pcall(function()
                local bufnr = nil
                if data.in_vimenter == true then
                  bufnr = vim.api.nvim_get_current_buf()
                  -- loaded by session.
                  if vim.api.nvim_get_option_value('buftype', { buf = bufnr }) == '' then return end
                end
                require('mini.starter').open(bufnr)
                vim.cmd('do User LazyVimStarted')
              end)
            end,
          },
        },
      })
    end,
  },
})
