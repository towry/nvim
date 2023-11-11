local au = require('userlib.runtime.au')

local M = {}

function M.load_on_startup()
  -- taken from AstroNvim
  local definitions = {
    {
      { 'BufReadPost' },
      {
        group = '_clear_fugitive_bufs',
        pattern = 'fugitive://*',
        callback = function() vim.cmd('set bufhidden=delete') end,
      },
    },
    {
      { 'BufWinEnter' },
      {
        group = '_disable_diagnostic_on_sth',
        pattern = '*',
        callback = function(args)
          local buf = args.buf
          if vim.b[buf].diagnostic_disable or vim.api.nvim_buf_line_count(0) > 40000 then
            vim.diagnostic.disable(buf)
            return
          end

          vim.schedule(function()
            if vim.wo.diff then
              vim.diagnostic.disable(buf)
              au.do_useraucmd('User IsDiffMode')
            end
          end)
        end,
      },
    },
    {
      { 'ExitPre' },
      {
        group = '_check_exit',
        callback = function()
          local disable = true
          if disable then return end
          --- https://github.com/neovim/neovim/issues/17256
          -- local tabs_count = #vim.api.nvim_list_tabpages()
          local tabs_count = 0
          local terms_count = require('userlib.terminal').terms_count()

          if tabs_count >= 2 or terms_count >= 1 then
            print(' ')
            print('  Are you sure to quit vim ? press `c` to cancel.')
            print(' ')
            local is_true_modifed = vim.bo.modified
            vim.cmd('set modified')
            vim.defer_fn(function()
              if not is_true_modifed then vim.cmd('set nomodified') end
            end, 1)
          end
        end,
      },
    },
    -- Emit `User FileOpened` event, used by the plugins.
    {
      { 'BufRead', 'BufWinEnter', 'BufNewFile' },
      {
        group = '_file_opened',
        nested = true,
        callback = function(args)
          local buftype = vim.api.nvim_get_option_value('buftype', { buf = args.buf })
          if not (vim.fn.expand('%') == '' or buftype == 'nofile') then
            vim.api.nvim_del_augroup_by_name('_file_opened')
            au.do_useraucmd(au.user_autocmds.FileOpened_User)

            vim.defer_fn(function()
              vim.schedule(function() au.do_useraucmd(au.user_autocmds.FileOpenedAfter_User) end)
            end, 10)
          end
        end,
      },
    },
    {
      'ColorScheme',
      {
        group = '_colorscheme',
        callback = function() au.fire_event(au.events.AfterColorschemeChanged) end,
      },
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
      },
    },
    {
      { 'BufReadPre', 'BufNewFile' },
      {
        group = '_no_lsp_diagnostic_inside_folders',
        pattern = '*/node_modules/*',
        callback = function(args)
          local bufnr = args.buf
          assert(bufnr ~= nil)
          vim.b[bufnr].diagnostic_disable = true
          vim.b[bufnr].autoformat_disable = true
        end,
      },
    },
    {
      { 'BufWritePost' },
      {
        group = 'Notify_about_config_change',
        pattern = '*/lua/user/plugins/*',
        callback = function()
          -- may being called two times due to the auto format write.
          vim.notify("Config changed, do not forget to run 'PrebundlePlugins' command!")
        end,
      },
    },
    {
      { 'BufWinEnter' },
      {
        group = 'clear_search_hl_on_buf_enter',
        callback = function()
          vim.schedule(function() vim.cmd('nohl') end)
        end,
      },
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
            vim.defer_fn(
              function()
                au.exec_useraucmd(au.user_autocmds.LazyUIEnterOncePost, {
                  data = ctx.data,
                })
              end,
              1
            )
          end)
        end,
      },
    },
    {
      { 'BufDelete', 'BufNew' },
      {
        group = '_after_buf_rename',
        pattern = '*',
        callback = function(ctx)
          vim.b[ctx.buf].project_nvim_cwd = nil
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
            vim.defer_fn(
              function()
                au.exec_useraucmd(au.user_autocmds.LazyUIEnterPost, {
                  data = ctx.data,
                })
              end,
              1
            )
          end)
        end,
      },
    },
  }

  ---////// user autocmds.
  local user_definitions = {
    {
      pattern = 'ProjectNvimSetPwd',
      group = '_set_dir_on_change_',
      callback = function(ctx)
        if vim.bo.buftype ~= '' then return end
        local data = ctx.data or {}
        local new_cwd = data.dir or nil
        ---@diagnostic disable-next-line: undefined-field
        if not new_cwd then new_cwd = vim.uv.cwd() end
        local buf_cwd, buf_cwd_short = vim.b[ctx.buf].project_nvim_cwd, vim.b[ctx.buf].project_nvim_cwd_short
        local cwd, cwd_short = require('userlib.runtime.utils').update_cwd_env(buf_cwd, buf_cwd_short)
        if vim.b[ctx.buf].did_set_cwd_short == cwd then return end
        vim.b[ctx.buf].did_set_cwd_short = cwd
        -- set cwd on this buffer.
        vim.b[ctx.buf].project_nvim_cwd_short = cwd_short
        vim.b[ctx.buf].relative_path = require('userlib.runtime.path').make_relative(vim.api.nvim_buf_get_name(ctx.buf),
          cwd)
      end,
    },
    {
      pattern = 'AlphaClosed',
      callback = function() au.do_useraucmd(au.user_autocmds.OnLeaveDashboard_User) end,
    },
    {
      pattern = 'VeryLazy',
      once = true,
      callback = function() require('user.config.theme').setup_theme() end,
    },
    {
      --- start dashboard
      pattern = au.user_autocmds.LazyUIEnter,
      once = true,
      callback = function()
        if vim.fn.argc(-1) ~= 0 then return end
        vim.schedule(
          function()
            au.exec_useraucmd(au.user_autocmds.DoEnterDashboard, {
              data = {
                in_vimenter = true,
              },
            })
          end
        )
      end,
    },
  }

  au.define_autocmds(definitions)
  au.define_user_autocmds(user_definitions)

  vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinEnter' }, {
    callback = function()
      if vim.bo.buftype ~= '' then return end
      local ok, cl = pcall(vim.api.nvim_win_get_var, 0, 'auto-cursorline')
      if ok and cl then
        vim.wo.cursorline = true
        vim.api.nvim_win_del_var(0, 'auto-cursorline')
      end
    end,
  })
  vim.api.nvim_create_autocmd({ 'InsertEnter', 'WinLeave' }, {
    callback = function()
      if vim.bo.buftype ~= '' then return end
      local cl = vim.wo.cursorline
      if cl then
        vim.api.nvim_win_set_var(0, 'auto-cursorline', cl)
        vim.wo.cursorline = false
      end
    end,
  })
end

function M.setup_events_on_startup() end

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
  opts = vim.tbl_deep_extend('force', {
    resize_kitty = false,
  }, opts or {})

  M.load_on_startup()
  M.setup_events_on_startup()

  if opts.resize_kitty then resize_kitty() end
  if type(opts.on_very_lazy) == 'function' then
    au.define_user_autocmd({
      pattern = 'VeryLazy',
      group = 'setup_on_very_lazy',
      once = true,
      callback = opts.on_very_lazy,
    })
  end
end

return M
