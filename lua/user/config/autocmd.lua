local au = require('userlib.runtime.au')

local M = {}

function M.load_on_startup()
  -- taken from AstroNvim
  local definitions = {
    {
      { 'TextYankPost' },
      {
        group = 'hl_on_yank',
        callback = function()
          vim.highlight.on_yank()
        end,
      },
    },
    {
      -- lazy insert enter
      { 'InsertEnter' },
      {
        group = 'lazy_insert_enter',
        once = true,
        callback = function()
          vim.defer_fn(
            vim.schedule_wrap(function()
              au.do_useraucmd('User LazyInsertEnter')
            end),
            10
          )
        end,
      },
    },
    {
      { 'CmdwinEnter' },
      {
        group = 'key_set_on_cmdwin',
        callback = function(ctx)
          local bufnr = ctx.buf
          assert(type(bufnr) == 'number')
          vim.b[bufnr].bufname = 'Cmdwin'
          local set = vim.keymap.set

          --- run command and reopen it
          set('n', '<F1>', '<CR>q:', {
            buffer = bufnr,
            silent = true,
          })
        end,
      },
    },
    {
      { 'VimLeavePre' },
      {
        group = 'force_shutdown_clients',
        callback = function()
          -- cause quit slow.
          -- vim.lsp.stop_client(vim.lsp.get_clients(), true)
        end,
      },
    },
    {
      { 'TermOpen' },
      {
        group = 'bind_key_on_term_open',
        pattern = 'term://*',
        callback = function()
          Ty.set_terminal_keymaps()
        end,
      },
    },
    {
      { 'BufReadPost' },
      {
        group = '_clear_fugitive_bufs',
        pattern = 'fugitive://*',
        callback = function()
          vim.cmd('set bufhidden=delete')
        end,
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
        end,
      },
    },
    {
      { 'ExitPre' },
      {
        group = '_check_exit',
        callback = function()
          local disable = true
          if disable then
            return
          end
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
              if not is_true_modifed then
                vim.cmd('set nomodified')
              end
            end, 1)
          end
        end,
      },
    },
    -- disable something on large buffer.
    {
      { 'BufReadPre' },
      {
        group = '_disable_on_large_buf',
        callback = function(ctx)
          local buf = ctx.buf
          -- if file size is big than 100000
          if require('userlib.runtime.buffer').is_big_file(ctx.buf) then
            vim.b[buf].is_big_file = true
            vim.b[buf].copilot_enabled = false
            vim.b[buf].autoformat_disable = true
            vim.b[buf].minicursorword_disable = true
            vim.b[buf].diagnostic_disable = true
            vim.b[buf].lsp_disable = true

            vim.api.nvim_create_augroup('disable_syntax_on_buf_' .. buf, { clear = true })
            vim.api.nvim_create_autocmd('BufReadPost', {
              group = 'disable_syntax_on_buf_' .. buf,
              buffer = buf,
              once = true,
              callback = vim.schedule_wrap(function()
                vim.bo[buf].syntax = ''
              end),
            })
          else
            vim.b[buf].is_big_file = false
          end
        end,
      },
    },
    -- enable foldexpr
    {
      { 'BufReadPost' },
      {
        group = 'enable_foldexpr_for_buf',
        callback = function(ctx)
          local buf = ctx.buf
          local lines = vim.api.nvim_buf_line_count(buf)
          if not vim.b[buf].is_big_file and lines < 10000 then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            -- foldtext with ts hi
            vim.wo.foldtext = ''
          else
            vim.wo.foldmethod = 'manual'
            vim.wo.foldexpr = ''
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
              vim.schedule(function()
                au.do_useraucmd(au.user_autocmds.FileOpenedAfter_User)
              end)
            end, 1)
          end
        end,
      },
    },
    {
      'ColorScheme',
      {
        group = '_colorscheme',
        callback = function()
          au.fire_event(au.events.AfterColorschemeChanged)
        end,
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
          vim.b[bufnr].lsp_disable = true
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
      { 'BufWritePost' },
      {
        group = 'notify_about_error_buf_save',
        callback = function(ctx)
          local bufnr = ctx.buf
          if vim.b[bufnr].lsp_disable or vim.b[bufnr].diagnostic_disable then
            return
          end
          if not vim.diagnostic.count then
            return
          end
          local counts = vim.diagnostic.count(bufnr)
          if counts and (counts[vim.diagnostic.severity.ERROR] or 0) > 0 then
            vim.schedule(function()
              vim.api.nvim_echo({ { string.format('buffer[%s] saved with error', bufnr), 'Comment' } }, true, {})
            end)
          end
        end,
      },
    },
    {
      { 'BufWinEnter' },
      {
        group = 'clear_search_hl_on_buf_enter',
        callback = function()
          vim.schedule(function()
            vim.cmd('nohl')
          end)
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
            -- au.exec_useraucmd(au.user_autocmds.LazyTheme, {
            --   data = ctx.data,
            -- })
            au.exec_useraucmd(au.user_autocmds.LazyUIEnterOncePre, {
              data = ctx.data,
            })
          end
          vim.schedule(function()
            au.exec_useraucmd(au.user_autocmds.LazyTheme, {
              data = ctx.data,
            })
            if should_defer then
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
        end,
      },
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
      },
    },
  }

  ---////// user autocmds.
  local user_definitions = {
    {
      pattern = 'ProjectNvimSetPwd',
      group = '_set_dir_on_change_',
      callback = function(ctx)
        if vim.bo.buftype ~= '' then
          return
        end
        local data = ctx.data or {}
        local new_cwd = data.dir or nil
        ---@diagnostic disable-next-line: undefined-field
        if not new_cwd then
          new_cwd = vim.uv.cwd()
        end
        local buf_cwd, buf_cwd_short = vim.b[ctx.buf].project_nvim_cwd, vim.b[ctx.buf].project_nvim_cwd_short
        local cwd, cwd_short = require('userlib.runtime.utils').update_cwd_env(buf_cwd, buf_cwd_short)
        if vim.b[ctx.buf].did_set_cwd_short == cwd then
          return
        end
        vim.b[ctx.buf].did_set_cwd_short = cwd
        -- set cwd on this buffer.
        vim.b[ctx.buf].project_nvim_cwd_short = cwd_short
        vim.b[ctx.buf].relative_path =
          require('userlib.runtime.path').make_relative(vim.api.nvim_buf_get_name(ctx.buf), cwd)
      end,
    },
    {
      pattern = 'AlphaClosed',
      callback = function()
        au.do_useraucmd(au.user_autocmds.OnLeaveDashboard_User)
      end,
    },
    {
      pattern = 'FugitiveChanged',
      callback = function()
        vim.defer_fn(require('userlib.git.gitinfo').update, 500)
      end,
    },
    {
      pattern = 'VeryLazy',
      once = true,
      callback = function()
        require('user.config.theme').setup_theme()
        --- TODO: fix me
        require('userlib.git.gitinfo').start()
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
            },
          })
        end)
      end,
    },
  }

  au.define_autocmds(definitions)
  au.define_user_autocmds(user_definitions)
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
      if resized then
        return
      end
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
      if not resized then
        return
      end
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

  if type(opts.on_very_lazy) == 'function' then
    au.define_user_autocmd({
      pattern = 'VeryLazy',
      group = 'setup_on_very_lazy',
      once = true,
      callback = opts.on_very_lazy,
    })
  end

  if vim.g.vscode then
    return
  end

  if opts.resize_kitty then
    resize_kitty()
  end
end

return M
