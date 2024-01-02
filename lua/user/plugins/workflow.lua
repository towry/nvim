local au = require('userlib.runtime.au')
local utils = require('userlib.runtime.utils')
local plug = require('userlib.runtime.pack').plug
local cmdstr = require('userlib.runtime.keymap').cmdstr

local function get_window_bufnr(winid)
  return vim.api.nvim_win_call(winid, function()
    return vim.fn.bufnr('%')
  end)
end
local function change_window_bufnr(winid, bufnr)
  vim.api.nvim_win_call(winid, function()
    vim.cmd(string.format('buffer %d', bufnr))
  end)
end

plug({
  {
    'anuvyklack/windows.nvim',
    dependencies = {
      'anuvyklack/middleclass',
    },
    keys = {
      {
        '<C-w>a',
        function()
          local aw = require('windows.autowidth')
          local awc = require('windows.config')
          aw.toggle()
          if awc.autowidth.enable then
            vim.notify('󰿆 Windows auto width enabled', vim.log.levels.INFO, {
              key = 'windows',
            })
          else
            vim.notify('󱙱 Windows auto width disabled', vim.log.levels.INFO, {
              key = 'windows',
            })
          end
        end,
        nowait = true,
        desc = 'Toggle auto size',
      },
      { '<C-w>m', '<cmd>WindowsMaximize<cr>', nowait = true, desc = 'Maximize window' },
      { '<C-w>=', '<cmd>WindowsEqualize<cr>', nowait = true, desc = 'Equallize window' },
      {
        '<C-w>x',
        function()
          local cur_win = vim.api.nvim_get_current_win()
          if vim.fn.winnr('$') <= 2 then
            vim.cmd('wincmd x')
            return
          end
          vim.schedule(function()
            local ok, winpick = pcall(require, 'window-picker')
            if not ok then
              vim.cmd('wincmd x')
              return
            else
              local picked = winpick.pick_window({
                autoselect_one = false,
                include_current_win = false,
                hint = 'floating-big-letter',
              })
              if not picked then
                return
              end
              local current_bufnr = get_window_bufnr(cur_win)
              local target_bufnr = get_window_bufnr(picked)
              change_window_bufnr(picked, current_bufnr)
              -- use wincmd to focus picked window.
              change_window_bufnr(cur_win, target_bufnr)
              vim.cmd(string.format('%dwincmd w', vim.fn.win_id2win(picked)))
              -- go back, so we can use quickly switch between those two window.
              vim.cmd('wincmd p')
            end
          end)
        end,
        desc = 'swap',
      },
    },
    enabled = true,
    event = 'WinNew',
    opts = {
      autowidth = {
        enable = false,
      },
      ignore = {
        buftype = vim.cfg.misc__buf_exclude,
        filetype = vim.cfg.misc__ft_exclude,
      },
      animation = {
        enable = false,
      },
    },
    config = function(_, opts)
      require('windows').setup(opts)
    end,
    init = function()
      au.define_autocmd('VimEnter', {
        once = true,
        callback = function()
          if vim.cfg.ui__window_equalalways then
            return
          end
          if vim.cfg.runtime__starts_in_buffer and vim.wo.diff then
            vim.cmd('WindowsEqualize')
          end
        end,
      })
    end,
    lazy = true,
    cmd = {
      'WindowsMaximize',
      'WindowsMaximizeVertically',
      'WindowsMaximizeHorizontally',
      'WindowsEqualize',
      'WindowsEnableAutowidth',
      'WindowsDisableAutowidth',
      'WindowsToggleAutowidth',
    },
  },

  ----- buffers
  {
    'kazhala/close-buffers.nvim',
    module = 'close_buffers',
    --- BDelete regex=term://
    keys = {
      { '<leader>bo', '<cmd>BDelete other<cr>', desc = 'Only' },
    },
    cmd = {
      'BDelete',
      'BWipeout',
    },
  },
  {
    'kwkarlwang/bufresize.nvim',
    event = 'WinResized',
    lazy = true,
    config = true,
  },

  {
    'pze/mini.bufremove',
    cond = not vim.cfg.runtime__starts_as_gittool,
    dev = false,
    keys = {
      {
        '<leader>bx',
        '<cmd>lua require("mini.bufremove").wipeout(0)<cr>',
        desc = 'Close current buffer',
      },
      {
        '<leader>bq',
        function()
          require('mini.bufremove').wipeout(0)
          vim.cmd('q')
        end,
        desc = 'Close current buffer and window',
      },
      {
        '<leader>bh',
        function()
          require('mini.bufremove').unshow(0)
        end,
        desc = 'Unshow current buffer',
      },
      {
        '<C-q>',
        function()
          require('userlib.workflow.close-buffer').close()
        end,
        desc = 'Quit current buffer',
      },
    },
  },

  --- open buffer last place.
  {
    'ethanholz/nvim-lastplace',
    cond = not vim.cfg.runtime__starts_as_gittool,
    event = { 'BufReadPre' },
    opts = {
      lastplace_ignore_buftype = vim.cfg.misc__buf_exclude,
      lastplace_ignore_filetype = vim.cfg.misc__ft_exclude,
      lastplace_open_folds = true,
    },
  },

  ----- grapple and portal
  {
    'cbochs/portal.nvim',
    enabled = false,
    cmd = { 'Portal' },
    keys = {

      {
        '<leader>o',
        function()
          local builtins = require('portal.builtin')

          local jumplist = builtins.jumplist.query({
            direction = 'backward',
            max_results = 5,
          })
          local harpoon = builtins.harpoon.query({
            direction = 'backward',
            max_results = 2,
          })
          require('portal').tunnel({ jumplist, harpoon })
        end,
        desc = 'Portal jump backward',
      },
      {
        '<leader>i',
        function()
          local builtins = require('portal.builtin')

          local jumplist = builtins.jumplist.query({
            direction = 'forward',
            max_results = 5,
          })
          local harpoon = builtins.harpoon.query({
            direction = 'forward',
            max_results = 2,
          })

          require('portal').tunnel({ jumplist, harpoon })
        end,
        desc = 'Portal jump forward',
      },
    },
    config = function()
      require('portal').setup({
        log_level = 'error',
        window_options = {
          relative = 'cursor',
          width = 80,
          height = 4,
          col = 2,
          focusable = false,
          border = vim.cfg.ui__float_border,
          noautocmd = true,
        },
        wrap = true,
        select_first = true,
        escape = {
          ['<esc>'] = true,
          ['<C-c>'] = true,
          ['q'] = true,
          ['<C-j>'] = true,
        },
      })

      vim.cmd('hi! link PortalBorder NormalFloat')
    end,
  },
  {
    enabled = false,
    'cbochs/grapple.nvim',
    keys = {
      { '<leader>bg', '<cmd>GrappleToggle<cr>', desc = 'Toggle grapple' },
      { '<leader>bp', '<cmd>GrapplePopup<cr>', desc = 'Popup grapple' },
      { '<leader>bc', '<cmd>GrappleCycle<cr>', desc = 'Cycle grapple' },
    },
    cmd = { 'GrappleToggle', 'GrapplePopup', 'GrappleCycle' },
    opts = {
      log_level = 'error',
      scope = 'git',
      integrations = {
        resession = false,
      },
    },
  },
  {
    'pze/project.nvim',
    branch = 'main',
    dev = false,
    cond = not vim.cfg.runtime__starts_as_gittool,
    name = 'project_nvim',
    cmd = { 'ProjectRoot' },
    event = 'VeryLazy',
    keys = {
      {
        '<leader>fP',
        '<cmd>ProjectRoot<cr>',
        desc = 'Call project root',
      },
    },
    config = function(_, opts)
      require('project_nvim').setup(opts)
    end,
    opts = {
      patterns = utils.root_patterns,
      --- order matters
      detection_methods = { 'pattern', 'lsp' },
      manual_mode = false,
      -- Table of lsp clients to ignore by name
      -- eg: { "efm", ... }
      ignore_lsp = utils.root_lsp_ignore,
      -- Don't calculate root dir on specific directories
      -- Ex: { "~/.cargo/*", ... }
      exclude_dirs = {
        '.cargo/',
        '~/.local',
        '~/.cache',
        'Library/',
        '.cache/',
        'dist/',
        'node_modules/',
        '.pnpm/',
      },
      -- Show hidden files in telescope
      show_hidden = false,
      -- When set to false, you will get a message when project.nvim changes your
      -- directory.
      silent_chdir = true,
      -- What scope to change the directory, valid options are
      -- * global (default)
      -- * tab
      -- * win
      scope_chdir = 'tab',
    },
  },
  {
    'Lilja/zellij.nvim',
    cond = vim.cfg.runtime__is_zellij,
    cmd = {
      'ZellijNewPane',
      'ZellijNewTab',
      'ZellijRenamePane',
      'ZellijRenameTab',
      'ZellijNavigateLeft',
      'ZellijNavigateRight',
      'ZellijNavigateUp',
      'ZellijNavigateDown',
    },
  },
  {
    'mrjones2014/smart-splits.nvim',
    keys = {
      {
        '<A-h>',
        cmdstr([[lua require("smart-splits").resize_left(vim.cfg.editor_resize_steps)]]),
        desc = 'Resize window to left',
      },
      {
        '<A-j>',
        cmdstr([[lua require("smart-splits").resize_down(vim.cfg.editor_resize_steps)]]),
        desc = 'Resize window to down',
      },
      {
        '<A-k>',
        cmdstr([[lua require("smart-splits").resize_up(vim.cfg.editor_resize_steps)]]),
        desc = 'Resize window to up',
      },
      {
        '<A-l>',
        cmdstr([[lua require("smart-splits").resize_right(vim.cfg.editor_resize_steps)]]),
        desc = 'Resize window to right',
      },
      {
        '<C-h>',
        cmdstr([[lua require("smart-splits").move_cursor_left()]]),
        desc = 'Move cursor to left window',
      },
      {
        '<C-j>',
        cmdstr([[lua require("smart-splits").move_cursor_down()]]),
        desc = 'Move cursor to down window',
      },
      {
        '<C-k>',
        cmdstr([[lua require("smart-splits").move_cursor_up()]]),
        desc = 'Move cursor to up window',
      },
      {
        '<C-l>',
        cmdstr([[lua require("smart-splits").move_cursor_right()]]),
        desc = 'Move cursor to right window',
      },
    },
    dependencies = {
      'kwkarlwang/bufresize.nvim',
    },
    build = './kitty/install-kittens.bash',
    config = function()
      local splits = require('smart-splits')

      splits.setup({
        default_amount = 3,
        -- Ignored filetypes (only while resizing)
        ignored_filetypes = {
          'nofile',
          'quickfix',
          'prompt',
          'qf',
        },
        -- Ignored buffer types (only while resizing)
        ignored_buftypes = { 'nofile', 'NvimTree' },
        resize_mode = {
          quit_key = {
            quit_key = '<ESC>',
            resize_keys = { 'h', 'j', 'k', 'l' },
          },
          hooks = {
            on_leave = function()
              require('bufresize').register()
            end,
          },
        },
        ignored_events = {
          'BufEnter',
          'WinEnter',
        },
        log_level = 'error',
        disable_multiplexer_nav_when_zoomed = true,
      })
    end,
  },

  {
    's1n7ax/nvim-window-picker',
    opts = {
      filter_rules = {
        autoselect_one = true,
        include_current_win = false,
        bo = {
          -- if the file type is one of following, the window will be ignored
          filetype = vim.cfg.misc__ft_exclude,

          -- if the file type is one of following, the window will be ignored
          buftype = vim.cfg.misc__buf_exclude,
        },
      },
      selection_chars = 'ABCDEFGHIJKLMNOPQRSTUVW',
    },
    keys = {
      {
        '<leader>bm',
        function()
          local buf = vim.api.nvim_get_current_buf()
          local win = require('window-picker').pick_window({
            autoselect_one = false,
            include_current_win = false,
          })
          if not win then
            return
          end
          require('mini.bufremove').unshow(buf)
          -- TODO: use bufstack.
          vim.api.nvim_set_current_win(win)
          vim.api.nvim_win_set_buf(win, buf)
        end,
        desc = 'Move buffer to another window',
      },
    },
  },

  {
    'kwkarlwang/bufjump.nvim',
    keys = {
      '<D-i>',
      '<D-o>',
      {
        -- super + i
        '<Char-0xAF>',
        "<cmd>lua require('bufjump').forward()<cr>",
        desc = 'Forward buf jump',
        noremap = true,
      },
      {
        -- super + o
        '<Char-0xBA>',
        "<cmd>lua require('bufjump').backward()<cr>",
        desc = 'Backward buf jump',
        noremap = true,
      },
    },
    opts = {
      forward = '<D-i>',
      backward = '<D-o>',
      on_success = nil,
    },
  },
})

plug({
  'towry/window-bufstack.nvim',
  cond = not vim.cfg.runtime__starts_as_gittool,
  dev = false,
  opts = {
    ignore_filetype = { 'oil' },
  },
  event = 'VeryLazy',
  keys = {
    {
      ']b',
      function()
        vim.g.direction = 'next'
        local bufstack = require('window-bufstack.bufstack')
        local next_buf = bufstack.peek_bufstack(0, {
          skip = 0,
          bottom = true,
        })
        if next_buf and next_buf > 0 then
          vim.api.nvim_win_set_buf(0, next_buf)
        else
          vim.cmd('bprevious')
        end
      end,
      desc = 'Next buffer in window',
    },
    {
      '[b',
      function()
        vim.g.direction = 'prev'
        local bufstack = require('window-bufstack.bufstack')
        local next_buf = bufstack.peek_bufstack(0, {
          skip = 1,
        })
        if next_buf and next_buf > 0 then
          bufstack.push(0, 0, { bottom = true })
          vim.api.nvim_win_set_buf(0, next_buf)
        else
          vim.cmd('bnext')
        end
      end,
      desc = 'Prev buffer in window',
    },
  },
  init = au.schedule_lazy(function()
    -- create a user command with nvim api
    vim.api.nvim_create_user_command('DebugWindowBufStack', function()
      vim.print(require('window-bufstack.bufstack').debug())
    end, {})
  end),
})

plug({
  'echasnovski/mini.doc',
  version = '*',
  ft = 'lua',
  config = true,
})

local cache_tcd = nil
plug({
  'echasnovski/mini.sessions',
  cond = not vim.cfg.runtime__starts_as_gittool,
  version = '*',
  event = {
    'VeryLazy',
  },
  opts = {
    autoread = false,
    autowrite = false,
    hooks = {
      pre = {
        read = function()
          vim.g.project_nvim_disable = true
          cache_tcd = vim.t[0].cwd
          -- go to root cd, otherwise buffer load is incrrect
          -- because of the proejct.nvim will change each buffer's cwd.
          vim.cmd.tcd(vim.cfg.runtime__starts_cwd)
        end,
        write = function()
          if utils.has_plugin('trailblazer.nvim') then
            vim.cmd('TrailBlazerSaveSession')
          end
        end,
      },
      post = {
        read = function()
          vim.g.project_nvim_disable = false
          if cache_tcd then
            vim.cmd.tcd(cache_tcd)
          end
          if utils.has_plugin('trailblazer.nvim') then
            vim.cmd('TrailBlazerLoadSession')
          end
        end,
      },
    },
  },
  init = au.schedule_lazy(function()
    vim.api.nvim_create_user_command('MakeSession', function()
      require('userlib.mini.session').make_session()
    end, {})
    vim.api.nvim_create_user_command('LoadSession', function()
      require('userlib.mini.session').load_session()
    end, {})
    -- keymaps
    local set = require('userlib.runtime.keymap').set
    set('n', '<leader>/l', '<cmd>LoadSession<cr>', { desc = 'Load session' })
    set('n', '<leader>/m', '<cmd>MakeSession<cr>', { desc = 'Make session' })
    -- legendary
    require('userlib.legendary').register('mini_session', function(lg)
      lg.funcs({
        {
          function()
            require('userlib.mini.session').make_session()
          end,
          desc = 'Make session',
        },
        {
          function()
            require('userlib.mini.session').load_session()
          end,
          desc = 'Load session',
        },
      })
    end)
  end),
})

plug({
  -- https://github.com/j-morano/buffer_manager.nvim
  -- 'j-morano/buffer_manager.nvim',
  'razak17/buffer_manager.nvim',
  enabled = false,
})

plug({
  'stevearc/stickybuf.nvim',
  cmd = { 'PinBuffer', 'PinBuftype', 'PinFiletype', 'Unpin' },
  opts = {},
  config = function()
    require('stickybuf').setup({
      get_auto_pin = function(bufnr)
        local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
        if buf_ft == 'DiffviewFiles' then
          -- this is a diffview tab, disable creating new windows
          -- (which would be the default behavior of handle_foreign_buffer)
          return {
            handle_foreign_buffer = function(buf) end,
          }
        end
        return require('stickybuf').should_auto_pin(bufnr)
      end,
    })
  end,
})
