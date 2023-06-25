local plug = require('libs.runtime.pack').plug

-- start screen
return plug({
  -- enable mini.starter
  {
    "echasnovski/mini.starter",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "VimEnter",
    opts = function()
      local pad = string.rep(" ", 0)
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require("mini.starter")
      --stylua: ignore
      local config = {
        silent = false,
        evaluate_single = true,
        items = {
          new_section("Find file", "Telescope find_files", "Telescope"),
          new_section("Recent files", "Telescope oldfiles", "Telescope"),
          new_section("Grep text", "Telescope live_grep", "Telescope"),
          ---
          new_section("Session load", [[SessionManager load_current_dir_session]], "Session"),
          new_section("Session delete", [[SessionManager delete_session]], "Session"),
          ---
          new_section("Lazy", "Lazy", "Built-in"),
          new_section("New file", "ene | startinsert", "Built-in"),
          new_section("Quit current", "q", "Built-in"),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(pad .. "░ ", false),
          starter.gen_hook.aligning("center", "center"),
        },
      }
      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      local starter = require("mini.starter")
      starter.setup(config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local pad_footer = string.rep(" ", 0)
          starter.config.footer = pad_footer .. "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
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
            callback = function()
              require('mini.starter').open()
            end,
          }
        }
      })
    end,
  },
})
