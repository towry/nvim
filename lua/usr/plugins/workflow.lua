local au = require('userlib.runtime.au')
local utils = require('userlib.runtime.utils')
local plug = require('userlib.runtime.pack').plug
local keymap = require('userlib.runtime.keymap')
local cmdstr = keymap.cmdstr

plug({
  {
    'kwkarlwang/bufresize.nvim',
    event = 'VeryLazy',
    enabled = true,
    opts = {
      register = {
        trigger_events = { 'WinResized', 'WinLeave' },
        keys = {},
      },
      resize = {
        trigger_events = {
          'VimResized',
        },
        increment = 1,
      },
    },
  },

  {
    'pze/mini.bufremove',
    cond = not vim.cfg.runtime__starts_as_gittool,
    dev = false,
    keys = {
      {
        '<leader>bd',
        '<cmd>lua require("mini.bufremove").delete(0)<cr>',
        desc = 'Close current buffer',
      },
      {
        '<C-c><C-d>',
        function()
          if vim.fn.exists('&winfixbuf') == 1 and vim.api.nvim_get_option_value('winfixbuf', { win = 0 }) then
            Ty.resize.block()
            vim.cmd('bd')
            Ty.resize.after_close()
            return
          end
          -- do not use wipeout, because bqf doesn't update bufnr after buffer
          -- is wipeout
          require('mini.bufremove').delete(0)
        end,
        desc = 'Delete current buffer',
        silent = false,
      },
      {
        '<leader>bq',
        function()
          require('mini.bufremove').delete(0)
          vim.schedule(function()
            local _, error = pcall(vim.cmd, 'hide')
            if error then
              vim.api.nvim_echo({ { 'Last window, press `<leader>bq` again to quit', 'Error' } }, false, {})
              local set = require('userlib.runtime.keymap').map_buf_thunk(0)
              set(
                'n',
                '<leader>bq',
                '<cmd>call v:lua.Ty.resize.block() <bar> q! <bar> call v:lua.Ty.resize.after_close() <cr>',
                { desc = 'Force quit' }
              )
            end
          end)
        end,
        desc = 'Close current buffer and window',
      },
      {
        '<C-c><C-q>',
        ':echo "close buffer " .. bufnr("%") .. " and window" <bar> :call v:lua.Ty.resize.block() <bar> q <bar> :call v:lua.Ty.resize.after_close() <cr>',
        'Quit current buffer and window',
        silent = false,
      },
      {
        '<leader>bk',
        ':call v:lua.Ty.resize.block() <bar> :hide <bar> :call v:lua.Ty.resize.after_close()<cr>',
        desc = 'Hide current window',
      },
      {
        '<C-c><C-k>',
        function()
          local tabs_count = vim.fn.tabpagenr('$')
          if tabs_count <= 1 then
            Ty.resize.block()
            vim.cmd('silent! hide | echo "hide current window"')
            Ty.resize.after_close()
            return
          end
          --- get current tab's window count
          local win_count = require('userlib.runtime.buffer').current_tab_windows_count()
          if win_count <= 1 then
            local choice = vim.fn.confirm('Close last window in tab?', '&Yes\n&No', 2)
            if choice == 2 then
              return
            end
            vim.cmd('silent! hide')
            return
          end
          Ty.resize.block()
          vim.cmd('silent! hide | echo "hide current window"')
          Ty.resize.after_close()
        end,
        desc = 'Hide current window',
        silent = false,
      },
      {
        '<leader>bh',
        function()
          require('mini.bufremove').unshow_in_window(0)
        end,
        desc = 'Unshow current buffer',
      },
      {
        '<C-c><C-c>',
        function()
          if vim.fn.exists('&winfixbuf') == 1 and vim.api.nvim_get_option_value('winfixbuf', { win = 0 }) then
            Ty.resize.block()
            vim.cmd('hide')
            Ty.resize.after_close()
            return
          end
          if vim.api.nvim_win_get_config(vim.api.nvim_get_current_win()).relative ~= '' then
            --- float window
            vim.cmd('close')
            return
          end
          vim.cmd([[echo "Unshow buffer " .. bufnr("%")]])
          require('mini.bufremove').unshow_in_window(0)
        end,
        desc = 'Unshow current buffer',
        silent = false,
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
      lastplace_open_folds = false,
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
    enabled = true,
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
      get_patterns = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == '' then
          return
        end
        return utils.get_ft_root_patterns(ft, true)
      end,
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
      -- When set to false, you will get a message when project.nvim changes your
      -- directory.
      silent_chdir = true,
      -- What scope to change the directory, valid options are
      -- * global (default)
      -- * tab
      -- * win
      scope_chdir = 'custom',
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
    'https://git.sr.ht/~swaits/zellij-nav.nvim',
    lazy = true,
    enabled = vim.cfg.runtime__is_zellij,
    event = 'VeryLazy',
    keys = {
      { '<c-h>', '<cmd>ZellijNavigateLeft<cr>', { silent = true, desc = 'navigate left' } },
      { '<c-j>', '<cmd>ZellijNavigateDown<cr>', { silent = true, desc = 'navigate down' } },
      { '<c-k>', '<cmd>ZellijNavigateUp<cr>', { silent = true, desc = 'navigate up' } },
      { '<c-l>', '<cmd>ZellijNavigateRight<cr>', { silent = true, desc = 'navigate right' } },
    },
    opts = {},
  },

  {
    'mrjones2014/smart-splits.nvim',
    -- 'pze/smart-splits.nvim',
    -- dev = true,
    enabled = not vim.cfg.runtime__is_zellij,
    -- lazy = vim.cfg.runtime__starts_as_gittool and false or true,
    event = 'VeryLazy',
    keys = {
      {
        '<C-\\><C-r>h',
        mode = { 'n', 't' },
        cmdstr([[lua require("smart-splits").resize_left(vim.cfg.editor_resize_steps)]]),
        desc = 'Start resize mode',
      },
      {
        '<C-\\><C-r>j',
        mode = { 'n', 't' },
        cmdstr([[lua require("smart-splits").resize_down(vim.cfg.editor_resize_steps)]]),
        desc = 'Resize window to down',
      },
      {
        '<C-\\><C-r>k',
        mode = { 'n', 't' },
        cmdstr([[lua require("smart-splits").resize_up(vim.cfg.editor_resize_steps)]]),
        desc = 'Resize window to up',
      },
      {
        '<C-\\><C-r>l',
        mode = { 'n', 't' },
        cmdstr([[lua require("smart-splits").resize_right(vim.cfg.editor_resize_steps)]]),
        desc = 'Resize window to right',
      },

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
    -- only if you use kitty term
    -- build = './kitty/install-kittens.bash',
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
              Ty.resize.record()
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
        'zw',
        function()
          local win = require('window-picker').pick_window({
            selection_chars = '123456789ABCDEFGHIJKLMN',
            autoselect_one = false,
            include_current_win = true,
            hint = 'floating-big-letter',
            prompt_message = 'Focus window: ',
          })
          if not win then
            return
          end
          vim.api.nvim_set_current_win(win)
        end,
        desc = 'Focus a window',
      },
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
          vim.api.nvim_set_current_win(win)
          vim.api.nvim_win_set_buf(win, buf)
        end,
        desc = 'Move buffer to another window',
      },
    },
  },

  {
    'kwkarlwang/bufjump.nvim',
    enabled = false,
    keys = {
      {
        -- super + i
        -- keymap.super('i'),
        '<C-n>',
        "<cmd>lua require('bufjump').forward()<cr>",
        desc = 'Forward buf jump',
        noremap = true,
      },
      {
        -- super + o
        -- keymap.super('o'),
        '<C-p>',
        "<cmd>lua require('bufjump').backward()<cr>",
        desc = 'Backward buf jump',
        noremap = true,
      },
      {
        -- '<M-i>',
        keymap.super('i'),
        [[<cmd>lua require('bufjump').forward_same_buf()<cr>]],
        desc = 'Forward in same buf jump',
      },
      {
        -- '<M-o>',
        keymap.super('o'),
        [[<cmd>lua require('bufjump').backward_same_buf()<cr>]],
        desc = 'Backward in same buf jump',
      },
    },
    opts = {
      forward_key = false,
      backward_key = false,
      on_success = function()
        vim.cmd([[execute "normal! g`\"zz"]])
      end,
    },
  },
})

plug({
  'towry/window-bufstack.nvim',
  cond = not vim.cfg.runtime__starts_as_gittool,
  dev = false,
  enabled = false,
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
          require('userlib.runtime.session').encode_session_vars()
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
          local libsession = require('userlib.runtime.session')
          local session_json = libsession.decode_session_vars()
          if session_json then
            libsession.restore_tabs_vars(session_json.tabs)
          end
        end,
      },
    },
  },
  init = au.schedule_lazy(function()
    au.define_autocmd('VimLeavePre', {
      group = 'make_session_before_exit',
      once = true,
      callback = function()
        require('userlib.mini.session').make_session(false)
      end,
    })
    vim.api.nvim_create_user_command('MakeSession', function()
      require('userlib.mini.session').make_session()
    end, {})
    vim.api.nvim_create_user_command('LoadSession', function()
      require('userlib.mini.session').load_session()
    end, {})
    -- keymaps
    local set = require('userlib.runtime.keymap').set
    set('n', '<leader>//', '<cmd>LoadSession<cr>', { desc = 'Load session' })
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
  'pze/cybu.nvim',
  branch = 'main',
  dev = false,
  enabled = false,
  event = 'VeryLazy',
  opts = {
    position = {
      relative_to = 'win',
      ---@type "topleft" | "topcenter" | "topright" | "centerleft" | "center" | "bottomright" | "centerright" | "bottomleft"
      anchor = 'bottomleft',
      max_win_height = 80,
      max_win_width = 0.9,
      vertical_offset = -1,
      horizontal_offset = -1,
    },
    display_time = 450,
    style = {
      path = 'tail',
      border = vim.cfg.ui__float_border,
      pading = 10,
      prefix = '..',
    },
    behavior = {
      mode = {
        default = {
          -- switch = 'immediate',
          switch = 'on_close',
          -- view = 'rolling',
          view = 'paging',
        },
      },
      show_on_autocmd = false,
    },
    filter = {
      unlisted = true,
    },
  },
  init = function()
    vim.api.nvim_create_augroup('cyu_quick_nav', { clear = true })
    vim.api.nvim_create_autocmd('User', {
      group = 'cyu_quick_nav',
      pattern = 'CybuOpen',
      callback = function()
        vim.g.user_nvim_pending = 1
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      group = 'cyu_quick_nav',
      pattern = 'CybuClose',
      callback = function()
        vim.g.user_nvim_pending = 0
      end,
    })
  end,
})

plug({
  --- better bn & bp
  'ton/vim-bufsurf',
  event = 'VeryLazy',
  enabled = false,
  keys = {
    {
      ']b',
      '<Plug>(buf-surf-forward)',
      desc = 'Next buf',
      silent = false,
      noremap = true,
    },
    {
      '[b',
      '<Plug>(buf-surf-back)',
      desc = 'Prev buf',
      silent = false,
      noremap = true,
    },
  },
  init = function()
    vim.g.BufSurfIgnore = ',Fidget'
  end,
})

plug({
  'chrisgrieser/nvim-early-retirement',
  event = 'VeryLazy',
  --- disabled because it affect the jumplist.
  enabled = false,
  opts = {
    notificationOnAutoClose = true,
    retirementAgeMins = 15,
    minimumBufferNum = 6,
    deleteBufferWhenFileDeleted = false,
  },
})

plug({
  'ariel-frischer/bmessages.nvim',
  cond = not vim.g.is_start_as_merge_tool,
  cmd = { 'Bmessages', 'Bmessagesvs', 'Bmessagessp', 'BmessagesEdit' },
  event = 'CmdlineEnter',
  opts = {
    split_type = 'split',
  },
})

plug({
  'toppair/reach.nvim',
  enabled = false,
  keys = {
    {
      '<localleader>,',
      function()
        require('reach').buffers({})
      end,
      desc = 'List buffers',
    },
  },

  opts = {
    show_current = true,
    actions = {
      split = '-',
      vertsplit = '|',
      tabsplit = ']',
      delete = '<Space>',
      priority = '=',
    },
  },
})
