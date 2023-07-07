local au = require('userlib.runtime.au')

local M = {}

function M.load_on_startup()
  -- local current_timeoutlen = vim.opt.timeoutlen:get() or 400

  local definitions = {
    -- taken from AstroNvim
    -- Emit `User FileOpened` event, used by the plugins.
    {
      { "BufRead", "BufWinEnter", "BufNewFile" },
      {
        group = "_file_opened",
        nested = true,
        callback = function(args)
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
          if not (vim.fn.expand "%" == "" or buftype == "nofile") then
            vim.api.nvim_del_augroup_by_name("_file_opened")
            au.do_useraucmd(au.user_autocmds.FileOpened_User)

            vim.defer_fn(function()
              vim.schedule(function()
                au.do_useraucmd(au.user_autocmds.FileOpenedAfter_User)
              end)
            end, 10)
          end
        end,
      },
    },
    {
      "ColorScheme",
      {
        group = "_colorscheme",
        callback = function()
          au.fire_event(au.events.AfterColorschemeChanged)
        end,
      }
    },
    {
      'LspAttach',
      {
        group = '_lsp_attach_event',
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          au.fire_event(au.events.onLspAttach, {
            client = client,
            bufnr = bufnr,
          })
        end,
      }
    },
    {
      { 'BufRead', 'BufNewFile' },
      {
        group = '_no_lsp_diagnostic_inside_folders',
        pattern = '*/node_modules/*',
        command = 'lua vim.diagnostic.disable(0)',
      }
    },
    ------------------------------------
    -- {
    --   { 'InsertEnter' },
    --   {
    --     group = 'no_insert_delay',
    --     callback = function()
    --       vim.opt.timeoutlen = 0
    --     end
    --   }
    -- },
    -- {
    --   { 'InsertLeave' },
    --   {
    --     group = 'no_insert_delay',
    --     callback = function()
    --       vim.opt.timeoutlen = current_timeoutlen
    --     end
    --   }
    -- },
    {
      { 'BufWritePost' },
      {
        group = 'Notify_about_config_change',
        pattern = '*/lua/user/plugins/*',
        callback = function()
          -- may being called two times due to the auto format write.
          vim.notify("Config changed, do not forget to run 'PrebundlePlugins' command!")
        end,
      }
    },
    {
      { 'BufWinEnter' },
      {
        group = 'clear_search_hl_on_buf_enter',
        callback = function()
          vim.schedule(function()
            vim.cmd('nohl')
          end)
        end
      }
    },
    {
      'UIEnter',
      {
        once = true,
        callback = function(ctx)
          local should_defer = not vim.cfg.runtime__starts_in_buffer
          if not should_defer then
            au.exec_useraucmd(au.user_autocmds.LazyTheme, {
              data = ctx.data,
            })
            au.exec_useraucmd(au.user_autocmds.LazyUIEnterOncePre, {
              data = ctx.data,
            })
          end
          vim.schedule(function()
            if should_defer then
              au.exec_useraucmd(au.user_autocmds.LazyTheme, {
                data = ctx.data,
              })
              au.exec_useraucmd(au.user_autocmds.LazyUIEnterOncePre, {
                data = ctx.data,
              })
            end
            au.exec_useraucmd(au.user_autocmds.LazyUIEnterOnce, {
              data = ctx.data,
            })
            --- maybe post event should be fired inside above event.
            vim.defer_fn(function()
              au.exec_useraucmd(au.user_autocmds.LazyUIEnterOncePost, {
                data = ctx.data,
              })
            end, 1)
          end)
        end
      }
    },
    {
      { 'UIEnter' },
      {
        group = '_lazy_ui_enter',
        callback = function(ctx)
          if not vim.g.lazy_ui_enter_tick then
            vim.g.lazy_ui_enter_tick = 1
          else
            vim.g.lazy_ui_enter_tick = vim.g.lazy_ui_enter_tick + 1
          end
          local should_defer = not vim.cfg.runtime__starts_in_buffer
          if not should_defer then
            au.exec_useraucmd(au.user_autocmds.LazyUIEnterPre, {
              data = ctx.data,
            })
          end
          vim.schedule(function()
            if should_defer then
              au.exec_useraucmd(au.user_autocmds.LazyUIEnterPre, {
                data = ctx.data,
              })
            end
            au.exec_useraucmd(au.user_autocmds.LazyUIEnter, {
              data = ctx.data,
            })
            vim.defer_fn(function()
              au.exec_useraucmd(au.user_autocmds.LazyUIEnterPost, {
                data = ctx.data,
              })
            end, 1)
          end)
        end,
      }
    },
  }

  ---////// user autocmds.
  local user_definitions = {
    {
      pattern = "AlphaClosed",
      callback = function()
        au.do_useraucmd(au.user_autocmds.OnLeaveDashboard_User)
      end
    },
    {
      pattern = au.user_autocmds.LazyUIEnterPre,
      once = true,
      callback = function()
        pcall(vim.cmd, 'colorscheme ' .. vim.cfg.ui__theme_name)
      end,
    },
    {
      --- start dashboard
      pattern = au.user_autocmds.LazyUIEnter,
      once = true,
      callback = function()
        if vim.fn.argc(-1) ~= 0 then
          return
        end
        vim.schedule(function()
          au.exec_useraucmd(au.user_autocmds.DoEnterDashboard, {
            data = {
              in_vimenter = true,
            }
          })
        end)
      end,
    }
  }

  au.define_autocmds(definitions)
  au.define_user_autocmds(user_definitions)
end

function M.setup_events_on_startup()
  -- will be fired at each client's attch
  au.register_event(au.events.onLspAttach, {
    name = "setup_formatter_on_buf",
    callback = function(args)
      require('userlib.lsp-format').choose_formatter_for_buf(args.client, args.bufnr)
      require('userlib.lsp-format.autoformat').attach(args.client, args.bufnr)
      local is_auto_format_enable_config = true
      if is_auto_format_enable_config then
        require('userlib.lsp-format.autoformat').enable()
      end
    end
  })
end

---resize kitty window, no padding when neovim is present.
local function resize_kitty()
  local kitty_aug = vim.api.nvim_create_augroup('kitty_aug', { clear = true })
  local resized = false
  vim.api.nvim_create_autocmd({ 'UIEnter' }, {
    group = kitty_aug,
    pattern = '*',
    callback = function()
      if resized then return end
      vim.schedule(function()
        resized = true
        vim.cmd(':silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=0 margin=0')
      end)
    end,
  })
  vim.api.nvim_create_autocmd('UILeave', {
    group = kitty_aug,
    pattern = '*',
    callback = function()
      if not resized then return end
      vim.cmd(':silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=8 margin=0')
    end,
  })
end

---@param opts? {resize_kitty?: boolean,on_very_lazy?:function}
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", {
    resize_kitty = false,
  }, opts or {})

  M.load_on_startup()
  M.setup_events_on_startup()

  if opts.resize_kitty then
    resize_kitty()
  end
  if type(opts.on_very_lazy) == 'function' then
    vim.api.nvim_create_augroup('setup_on_very_lazy', { clear = true })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      group = 'setup_on_very_lazy',
      once = true,
      callback = opts.on_very_lazy,
    })
  end
end

return M
