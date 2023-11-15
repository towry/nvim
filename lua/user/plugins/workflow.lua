local au = require('userlib.runtime.au')
local plug = require('userlib.runtime.pack').plug
local cmdstr = require('userlib.runtime.keymap').cmdstr

plug({
  {
    -- 'anuvyklack/hydra.nvim',
    'pze/hydra.nvim',
    keys = {
      {
        '<C-w>',
        function()
          if vim.bo.filetype == 'TelescopePrompt' then return '<C-w>' end
          return cmdstr([[lua require("userlib.hydra.window").open_window_hydra(true)]])
        end,
        desc = 'Window operations',
        nowait = true,
        expr = true,
      },
    },
    config = function()
      -- vim.cmd('hi! link HydraHint NormalFloat')
      -- vim.cmd('hi! link HydraBorder NormalFloat')
    end,
  },

  {
    'anuvyklack/windows.nvim',
    dependencies = {
      'anuvyklack/middleclass',
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
      vim.opt.equalalways = vim.cfg.ui__window_equalalways
      require('windows').setup(opts)
    end,
    init = function()
      au.define_autocmd('VimEnter', {
        once = true,
        callback = function()
          if vim.cfg.ui__window_equalalways then return end
          if vim.cfg.runtime__starts_in_buffer and vim.wo.diff then vim.cmd('WindowsEqualize') end
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
      { '<leader>bo', '<cmd>BDelete other<cr>', desc = 'Only' }
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
        function() require('mini.bufremove').unshow(0) end,
        desc = 'Unshow current buffer',
      },
      {
        '<S-q>',
        function()
          local current_buf = vim.api.nvim_get_current_buf()
          local mb = require('mini.bufremove')
          local bufstack = require('window-bufstack.bufstack')
          bufstack.ignore_next()
          --- buffer is displayed in other window.
          if #vim.fn.win_findbuf(vim.fn.bufnr('%')) > 1 then
            mb.unshow_in_window(current_buf)
          else
            mb.delete(current_buf)
          end
          local next_buf = bufstack.pop()
          -- if not valid buf
          if next_buf and not vim.api.nvim_buf_is_valid(next_buf) then
            next_buf = nil
          end
          -- has current tab have more than 1 window?
          local current_tab_windows_count = #vim.fn.tabpagebuflist(vim.fn.tabpagenr())
          if not next_buf then
            if current_tab_windows_count > 1 then
              vim.cmd('q')
            else
              if require('userlib.runtime.buffer').is_empty_buffer(current_buf) then
                vim.cmd('q')
              else
                vim.cmd('enew')
              end
            end
          else
            vim.api.nvim_win_set_buf(0, next_buf)
          end
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
      { '<leader>bp', '<cmd>GrapplePopup<cr>',  desc = 'Popup grapple' },
      { '<leader>bc', '<cmd>GrappleCycle<cr>',  desc = 'Cycle grapple' },
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
    'telescope.nvim',
    dependencies = {
      {
        'pze/project.nvim',
        branch = 'main',
        dev = false,
        cond = not vim.cfg.runtime__starts_as_gittool,
        name = 'project_nvim',
        cmd = { 'ProjectRoot' },
        event = {
          'BufReadPre',
          'BufNewFile',
        },
        keys = {
          {
            '<leader>f[',
            [[<cmd>lua require('userlib.finder.project_session_picker').session_projects()<cr>]],
            desc = 'Session projects',
          },
          {
            '<leader>fP',
            '<cmd>ProjectRoot<cr>',
            desc = 'Call project root',
          },
          {
            '<leader>fp',
            function()
              local actions = require('telescope.actions')
              local state = require('telescope.actions.state')
              require('userlib.runtime.utils').plugin_schedule('project_nvim', function()
                require('telescope').extensions.projects.projects(require('telescope.themes').get_dropdown({
                  cwd = vim.cfg.runtime__starts_cwd,
                  attach_mappings = function(prompt_bufnr, _map)
                    local on_project_selected = function()
                      local entry_path = state.get_selected_entry().value
                      if not entry_path then return end
                      local new_cwd = entry_path

                      require('userlib.hydra.folder-action').open(new_cwd, prompt_bufnr)
                    end
                    actions.select_default:replace(on_project_selected)
                    return true
                  end,
                }))
              end)
            end,
            desc = 'Projects',
          },
        },
        config = function(_, opts)
          require('project_nvim').setup(opts)
          require('telescope').load_extension('projects')
        end,
        opts = {
          patterns = require('userlib.runtime.utils').root_patterns,
          --- order matters
          detection_methods = { 'pattern', 'lsp' },
          manual_mode = false,
          -- Table of lsp clients to ignore by name
          -- eg: { "efm", ... }
          ignore_lsp = require('userlib.runtime.utils').root_lsp_ignore,
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
    },
  },
  {
    'mrjones2014/smart-splits.nvim',
    keys = {
      {
        '<A-h>',
        cmdstr([[lua require("smart-splits").resize_left(vim.cfg.editor_resize_steps)]]),
        desc =
        'Resize window to left'
      },
      {
        '<A-j>',
        cmdstr([[lua require("smart-splits").resize_down(vim.cfg.editor_resize_steps)]]),
        desc =
        'Resize window to down'
      },
      {
        '<A-k>',
        cmdstr([[lua require("smart-splits").resize_up(vim.cfg.editor_resize_steps)]]),
        desc =
        'Resize window to up'
      },
      {
        '<A-l>',
        cmdstr([[lua require("smart-splits").resize_right(vim.cfg.editor_resize_steps)]]),
        desc =
        'Resize window to right'
      },
      {
        '<C-h>',
        cmdstr([[lua require("smart-splits").move_cursor_left()]]),
        desc =
        'Move cursor to left window'
      },
      {
        '<C-j>',
        cmdstr([[lua require("smart-splits").move_cursor_down()]]),
        desc =
        'Move cursor to down window'
      },
      {
        '<C-k>',
        cmdstr([[lua require("smart-splits").move_cursor_up()]]),
        desc =
        'Move cursor to up window'
      },
      {
        '<C-l>',
        cmdstr([[lua require("smart-splits").move_cursor_right()]]),
        desc =
        'Move cursor to right window'
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
            on_leave = function() require('bufresize').register() end,
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
          if not win then return end
          require('mini.bufremove').unshow(buf)
          -- TODO: use bufstack.
          vim.api.nvim_set_current_win(win)
          vim.api.nvim_win_set_buf(win, buf)
        end,
        desc = 'Move buffer to another window',
      }
    }
  },

  {
    'ThePrimeagen/harpoon',
    dev = false,
    event = 'User LazyUIEnterOncePost',
    keys = {
      {
        '<leader>fh',
        '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>',
        desc = 'Toggle harpoon UI',
      },
      --- marks as m also create harpoon mark.
      {
        'mm',
        function()
          require('harpoon.mark').add_file()
          return 'mm'
        end,
        expr = true,
        nowait = true,
        silent = false,
      },
    },
    opts = function()
      return {
        menu = {
          width = vim.api.nvim_win_get_width(0) - 6,
        },
        global_settings = {
          excluded_filetypes = vim.cfg.misc__ft_exclude,
        },
        mark_branch = false,
        -- get_project_key = function()
        --   return vim.cfg.runtime__starts_cwd
        -- end,
      }
    end,
    config = function(_, opts)
      require('harpoon').setup(opts)
      au.register_event(au.events.AfterColorschemeChanged, {
        name = 'harpoon_ui',
        immediate = true,
        callback = function()
          vim.cmd('hi! link HarpoonWindow NormalFloat')
          vim.cmd('hi! link HarpoonBorder NormalFloat')
        end,
      })
    end,
    init = function() vim.g.harpoon_log_level = 'warn' end,
  },
  {
    'kwkarlwang/bufjump.nvim',
    keys = {
      '<D-i>',
      '<D-o>',
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
  version = 'v1.0.5',
  dev = false,
  opts = {
    ignore_filetype = { 'oil' },
  },
  lazy = false,
  keys = {
    {
      '[b',
      function()
        local bufstack = require('window-bufstack.bufstack')
        local next_buf = bufstack.peek_bufstack(0, 1)
        if next_buf then
          vim.api.nvim_win_set_buf(0, next_buf)
        else
          vim.cmd('bprevious')
        end
      end,
      desc = 'Previous buffer'
    },
    {
      ']b',
      function()
        local bufstack = require('window-bufstack.bufstack')
        local next_buf = bufstack.peek_bufstack(0, 1)
        if next_buf then
          vim.api.nvim_win_set_buf(0, next_buf)
        else
          vim.cmd('bnext')
        end
      end,
      desc = 'Next buffer'
    },
  }
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
  cmd = {
    'MakeSession',
    'LoadSession',
  },
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
      },
      post = {
        read = function()
          vim.g.project_nvim_disable = false
          if cache_tcd then vim.cmd.tcd(cache_tcd) end
        end,
      }
    }
  },
  init = function()
    require('userlib.legendary').register('mini_session', function(lg)
      lg.funcs({
        {
          function()
            local MS = require('mini.sessions')
            local branch_name = vim.fn['FugitiveHead']() or 'temp'
            local cwd = vim.fn.fnameescape(vim.cfg.runtime__starts_cwd)
            local session_name = string.format('%s_%s', branch_name, cwd)
            -- replace slash, space, backslash, dot etc specifical char in session_name to underscore
            session_name = string.gsub(session_name, '[/\\ .]', '_')
            MS.write(session_name, {
              force = true,
            })
          end,
          desc = 'Make session',
        },
        {
          function()
            local MS = require('mini.sessions')
            local branch_name = vim.fn['FugitiveHead']() or 'temp'
            local cwd = vim.fn.fnameescape(vim.cfg.runtime__starts_cwd)
            local session_name = string.format('%s_%s', branch_name, cwd)
            -- replace slash, space, backslash, dot etc specifical char in session_name to underscore
            session_name = string.gsub(session_name, '[/\\ .]', '_')
            MS.read(session_name, {
              -- do not delete unsaved buffer.
              force = false,
              verbose = true,
            })
          end,
          desc = 'Load session',
        }
      })
    end)
  end,
})
