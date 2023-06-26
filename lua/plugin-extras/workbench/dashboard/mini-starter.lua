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
        evaluate_single = true,
        items = {
          new_section("F ~ Find file", 'lua require("libs.telescope.pickers").project_files()', "Telescope"),
          new_section("R ~ Recent files",
            'lua require("libs.telescope.pickers").project_files({cwd_only=true,oldfiles=true})', "Telescope"),
          new_section("S ~ Grep text", 'lua require("telescope").extensions.live_grep_args.live_grep_args()', "Telescope"),
          ---
          new_section("/ ~ Session load", [[SessionManager load_current_dir_session]], "Session"),
          new_section("_ ~ Session delete", [[SessionManager delete_session]], "Session"),
          ---
          new_section("L ~ Lazy", "Lazy", "Built-in"),
          new_section("N ~ New file", "ene | startinsert", "Built-in"),
          new_section("Q ~ Quit current", "q", "Built-in"),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(pad .. "░ ", false),
          starter.gen_hook.aligning("center", "center"),
        },
        query_updaters = 'abcdefghilmnopqrstuvwxyz0123456789_-./',
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
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniStarterOpened",
        callback = function(ctx)
          if show_lazy_cb then
            require("lazy").show()
            show_lazy_cb = false
          end
          local bufnr = ctx.buf
          if not bufnr then return end
          vim.keymap.set('n', 'k', [[<cmd>lua MiniStarter.update_current_item('prev')<CR>]],
            { buffer = bufnr, nowait = true, silent = true })
          vim.keymap.set('n', 'j', [[<cmd>lua MiniStarter.update_current_item('next')<CR>]],
            { buffer = bufnr, nowait = true, silent = true })
        end,
      })

      local starter = require("mini.starter")
      starter.setup(config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        once = true,
        callback = function()
          local Path = require('libs.runtime.path')
          local git = require('libs.git.utils')
          local stats = require("lazy").stats()

          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          starter.config.footer = "░  Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          starter.config.header = table.concat({
            "Hello, Towry",
            " ",
            ('%s · %s'):format("  " ..
              Path.home_to_tilde(vim.loop.cwd()),
              '  ' .. (git.get_git_abbr_head() or '/'))
          }, '\n')
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
