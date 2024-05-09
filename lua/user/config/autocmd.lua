--- https://github.com/akinsho/dotfiles/blob/0567c6786a7ead5c826f4b4c86776ec715223157/.config/nvim/plugin/autocommands.lua#L141
local au = require('userlib.runtime.au')

local M = {}
local group_name = 'user_config_group'

function M.load_on_startup()
  -- taken from AstroNvim
  local definitions = {
    {
      { 'VimEnter', 'WinEnter', 'BufWinEnter' },
      {
        group = group_name,
        pattern = '*',
        command = 'setlocal cursorline',
        desc = 'Hi active window cursorline',
      },
    },
    {
      { 'WinLeave' },
      {
        group = group_name,
        pattern = '*',
        command = 'setlocal nocursorline',
        desc = 'DeHi non-active window cursorline',
      },
    },
    {
      { 'WinClosed' },
      {
        group = group_name,
        callback = function(ctx)
          local winid = tonumber(ctx.match)
          local cur = vim.api.nvim_get_current_win()
          if winid ~= cur then
            return
          end
          vim.cmd('wincmd p')
        end,
        desc = 'Go to prev win after curr win closed',
      },
    },
    {
      { 'CursorMovedI', 'InsertLeave' },
      {
        group = group_name,
        pattern = '*',
        command = "if pumvisible() == 0 && !&pvw && getcmdwintype() == ''|pclose|endif",
        desc = 'Close the popup-menu automatically',
      },
    },
    {
      { 'BufNew' },
      {
        group = group_name,
        pattern = '*',
        callback = function(args)
          local bufname = vim.api.nvim_buf_get_name(args.buf)
          local root, line = bufname:match('^(.*):(%d+)$')
          if vim.fn.filereadable(bufname) == 0 and root and line and vim.fn.filereadable(root) == 1 then
            vim.schedule(function()
              vim.cmd.edit({ args = { root } })
              pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(line), 0 })
              vim.api.nvim_buf_delete(args.buf, { force = true })
            end)
          end
        end,
        desc = 'Edit files with :line at the end',
      },
    },
    -- +---
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
      --- create jump point, in case of line number/search jump etc
      'CmdlineEnter',
      {
        group = group_name,
        command = "normal! m'",
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
          set('n', 'q', '<C-w>c', {
            buffer = bufnr,
            silent = true,
            nowait = true,
            noremap = true,
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
      { 'TermRequest' },
      {
        group = 'save_term_cwd',
        callback = function(ev)
          if string.sub(vim.v.termrequest, 1, 4) == '\x1b]7;' then
            local dir = string.gsub(vim.v.termrequest, '\x1b]7;file://[^/]*', '')
            if vim.fn.isdirectory(dir) == 0 then
              vim.notify('invalid dir: ' .. dir)
              return
            end
            vim.api.nvim_buf_set_var(ev.buf, 'osc7_dir', dir)
            if vim.o.autochdir and vim.api.nvim_get_current_buf() == ev.buf then
              vim.cmd.cd(dir)
            end
          end
        end,
      },
    },
    {
      { 'TermOpen' },
      {
        group = 'bind_key_on_term_open',
        pattern = 'term://*',
        callback = function(ctx)
          Ty.set_terminal_keymaps(ctx.buf)
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
      -- before modeline
      { 'BufRead' },
      {
        group = 'enable_foldexpr_for_buf',
        callback = function(ctx)
          --- https://github.com/nvim-telescope/telescope.nvim/issues/699
          --- https://github.com/nvim-treesitter/nvim-treesitter/issues/1337
          local buf = ctx.buf
          local lines = vim.api.nvim_buf_line_count(buf)
          if vim.b[buf].is_big_file or lines > 10000 then
            vim.wo.foldmethod = 'manual'
            vim.wo.foldexpr = ''
            vim.schedule(function()
              vim.cmd('normal! zX')
            end)
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
        local runtimeutils = require('userlib.runtime.utils')
        if vim.bo.buftype ~= '' then
          return
        end
        local curbuf = vim.api.nvim_get_current_buf()
        local data = ctx.data or {}
        local new_cwd = data.dir or nil
        ---@diagnostic disable-next-line: undefined-field
        if not new_cwd then
          new_cwd = safe_cwd()
        end
        if vim.t.Cwd ~= new_cwd and ctx.buf == curbuf then
          -- project visits
          runtimeutils.use_plugin('mini.visits', function(visits)
            visits.add_label('visit_projects', new_cwd, vim.cfg.runtime__starts_cwd)
          end)
        end
        if not vim.t.CwdLocked then
          vim.cmd.tcd(new_cwd)
        end
        local buf_cwd, buf_cwd_short = vim.b[ctx.buf].project_nvim_cwd, vim.b[ctx.buf].project_nvim_cwd_short
        local cwd, cwd_short = runtimeutils.update_cwd_env(buf_cwd, buf_cwd_short)
        if vim.b[ctx.buf].did_set_cwd_short == cwd and cwd ~= nil then
          return
        end
        vim.b[ctx.buf].did_set_cwd_short = cwd
        -- set cwd on this buffer.
        vim.b[ctx.buf].project_nvim_cwd_short = cwd_short
        -- vim.b[ctx.buf].relative_path =
        --   require('userlib.runtime.path').make_relative(vim.api.nvim_buf_get_name(ctx.buf), cwd)
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
