local au = require('libs.runtime.au')
local plug = require('libs.runtime.pack').plug

-- start screen
return plug({
  -- enable mini.starter
  {
    "echasnovski/mini.starter",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    opts = function()
      local pad = string.rep(" ", 0)
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require("mini.starter")
      --stylua: ignore
      local config = {
        silent = true,
        evaluate_single = false,
        items = {
          ---
          new_section("Session load", [[SessionManager load_current_dir_session]], "Session"),
          new_section("Session list", [[SessionManager load_session]], "Session"),
          ---
          new_section("Git Branchs", "Telescope git_branches show_remote_tracking_branches=false", "Built-in"),
          new_section("Lazy", "Lazy", "Built-in"),
          new_section("Quit current", "q", "Built-in"),
          --- last.
          starter.sections.recent_files(9, true, false),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(pad .. "░ ", false),
          starter.gen_hook.aligning("center", "center"),
        },
        -- remove number from query since we need it as v:count
        query_updaters = 'abcdefghijklmnopqrstuvwxyz_-.'
      }
      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      local show_lazy_cb = false
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        show_lazy_cb = true
      end
      local starter = require("mini.starter")
      starter.setup(config)

      local update_header_opts = function()
        local Path = require('libs.runtime.path')
        local git = require('libs.git.utils')

        starter.config.header = table.concat({
          ('%s · %s'):format("  " ..
            Path.home_to_tilde(vim.uv.cwd()),
            '  ' .. (git.get_git_abbr_head() or '/'))
        }, '\n')
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniStarterOpened",
        callback = function(ctx)
          vim.b.minianimate_disable = true
          if show_lazy_cb then
            require("lazy").show()
            show_lazy_cb = false
          end
          local bufnr = ctx.buf
          if not bufnr then return end
          vim.keymap.set('n', 'K', [[<cmd>lua MiniStarter.update_current_item('prev')<CR>]],
            { buffer = bufnr, nowait = true, silent = true })
          vim.keymap.set('n', 'J', [[<cmd>lua MiniStarter.update_current_item('next')<CR>]],
            { buffer = bufnr, nowait = true, silent = true })

          vim.api.nvim_create_augroup('_dashboard_dir_changed', { clear = true })
          vim.api.nvim_create_autocmd('DirChanged', {
            group = '_dashboard_dir_changed',
            buffer = bufnr,
            callback = function()
              update_header_opts()
              pcall(starter.refresh)
            end
          })

          au.define_autocmd({ 'VimResized', 'WinResized' }, {
            group = '_refresh_starter',
            buffer = bufnr,
            command = 'lua MiniStarter.refresh(1)',
          })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        once = true,
        callback = function()
          local stats = require("lazy").stats()

          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          starter.config.footer = table.concat({
            " " .. stats.count,
            " · ",
            " " .. ms .. "ms"
          }, ' ')
          update_header_opts()
          pcall(starter.refresh)
        end,
      })
    end,
    init = function()
      -- listen enter dashboard event.
      local au = require('libs.runtime.au')
      au.define_autocmds({
        {
          "User",
          {
            group = '_plugin_enter_dashboard',
            pattern = au.user_autocmds.DoEnterDashboard,
            callback = function(ctx)
              local data = ctx.data or {}
              pcall(function()
                local bufnr = nil
                if data.in_vimenter == true then
                  bufnr = vim.api.nvim_get_current_buf()
                end
                require('mini.starter').open(bufnr)
                vim.cmd('do User LazyVimStarted')
              end)
            end,
          }
        }
      })
    end,
  },
})
