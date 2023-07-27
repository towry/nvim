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
          if vim.bo.filetype == 'TelescopePrompt' then
            return '<C-w>';
          end
          return cmdstr([[lua require("userlib.hydra.window").open_window_hydra(true)]])
        end,
        desc = 'Window operations',
        nowait = true,
        expr = true,
      }
    },
    config = function()
      vim.cmd('hi! link HydraHint NormalFloat')
      vim.cmd('hi! link HydraBorder NormalFloat')
    end,
  },

  {
    'anuvyklack/windows.nvim',
    dependencies = {
      'anuvyklack/middleclass',
    },
    enabled = true,
    event = 'User LazyUIEnterOnce',
    opts = {
      ignore = {
        buftype = vim.cfg.misc__buf_exclude,
        filetype = vim.cfg.misc__ft_exclude,
      },
      animation = {
        enable = false,
      }
    },
    config = function(_, opts)
      require('windows').setup(opts)
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

  {
    -- https://github.com/kevinhwang91/nvim-bqf
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    dependencies = {
      { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
    },
    config = function()
      vim.cmd('hi! link BqfPreviewBorder NormalFloat')
      vim.cmd('hi! link BqfPreviewFloat NormalFloat')
    end,
  },

  ----- buffers
  {
    'kazhala/close-buffers.nvim',
    module = 'close_buffers',
    --- BDelete regex=term://
    cmd = {
      'BDelete',
      'BWipeout',
    }
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
        function()
          require('mini.bufremove').unshow(0)
        end,
        desc = 'Unshow current buffer',
      },
      {
        '<S-q>',
        function()
          local buftype = vim.bo.buftype
          if buftype ~= "" then
            require('mini.bufremove').wipeout(0)
            if not vim.tbl_contains({
                  'terminal',
                }, buftype) then
              vim.cmd('q')
            end
            return
          end
          local valid_buf_count = #(require('userlib.runtime.buffer').list_normal_bufnrs())
          if valid_buf_count <= 1 then
            require('mini.bufremove').wipeout(0)
            vim.schedule(function()
              au.exec_useraucmd(au.user_autocmds.DoEnterDashboard, {
                data = {
                  in_vimenter = true,
                }
              })
            end)
            return
          end
          require('mini.bufremove').wipeout(0)
        end,
        desc = 'Quit current buffer',
      }
    }
  },

  --- open buffer last place.
  {
    'ethanholz/nvim-lastplace',
    event = { 'BufReadPre', },
    opts = {
      lastplace_ignore_buftype = vim.cfg.misc__buf_exclude,
      lastplace_ignore_filetype = vim.cfg.misc__ft_exclude,
      lastplace_open_folds = true,
    }
  },

  ----- grapple and portal
  {
    'cbochs/portal.nvim',
    cmd = { 'Portal' },
    keys = {

      {
        '<leader>o',
        function()
          local builtins = require('portal.builtin')

          local jumplist = builtins.jumplist.query({
            direction = 'backward',
            max_results = 3,
          })
          local harpoon = builtins.harpoon.query({
            direction = 'backward',
            max_results = 1,
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
            max_results = 3,
          })
          local harpoon = builtins.harpoon.query({
            direction = 'forward',
            max_results = 1,
          })

          require('portal').tunnel({ jumplist, harpoon })
        end,
        desc = 'Portal jump forward',
      }
    },
    config = function()
      require('portal').setup({
        log_level = 'error',
        window_options = {
          relative = "cursor",
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
        }
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
    }
  },
  {
    'telescope.nvim',
    dependencies = {
      {
        'pze/project.nvim',
        branch = 'feat/more-api',
        dev = false,
        name = 'project_nvim',
        cmd = { 'ProjectRoot' },
        event = {
          'BufRead',
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
              local actions = require("telescope.actions")
              local state = require("telescope.actions.state")
              require('userlib.runtime.utils').plugin_schedule('project_nvim', function()
                require('telescope').extensions.projects.projects(require('telescope.themes').get_dropdown({
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
          }
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
            ".cargo/",
            "~/.local",
            "~/.cache",
            "Library/",
            ".cache/",
            "dist/",
            "node_modules/",
            ".pnpm/"
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
        }
      }
    }
  },
  {
    'Shatur/neovim-session-manager',
    cmd = { 'SessionManager' },
    keys = {
      {
        '<leader>/s',
        '<cmd>SessionManager load_session<CR>',
        desc = 'Load current session',
      }
    },
    config = function()
      local session_manager = require('session_manager')
      local Path = require('plenary.path')

      session_manager.setup({
        sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),             -- The directory where the session files will be saved.
        path_replacer = '__',                                                    -- The character to which the path separator will be replaced for session files.
        colon_replacer = '++',                                                   -- The character to which the colon symbol will be replaced for session files.
        autoload_mode = require('session_manager.config').AutoloadMode.Disabled, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
        autosave_last_session = true,                                            -- Automatically save last session on exit and on session switch.
        autosave_ignore_not_normal = true,                                       -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
        autosave_ignore_filetypes = vim.tbl_extend('force',
          {                                                                      -- All buffers of these file types will be closed before the session is saved.
            'gitcommit',
            'toggleterm',
            'term',
            'nvimtree'
          }, vim.cfg.misc__ft_exclude),
        autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
        max_path_length = 0,              -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
      })
    end,
  },

  {
    'mrjones2014/smart-splits.nvim',
    keys = {
      { '<A-h>', cmdstr([[lua require("smart-splits").resize_left()]]),       desc = 'Resize window to left' },
      { '<A-j>', cmdstr([[lua require("smart-splits").resize_down()]]),       desc = 'Resize window to down' },
      { '<A-k>', cmdstr([[lua require("smart-splits").resize_up()]]),         desc = 'Resize window to up' },
      { '<A-l>', cmdstr([[lua require("smart-splits").resize_right()]]),      desc = 'Resize window to right' },
      { '<C-h>', cmdstr([[lua require("smart-splits").move_cursor_left()]]),  desc = 'Move cursor to left window' },
      { '<C-j>', cmdstr([[lua require("smart-splits").move_cursor_down()]]),  desc = 'Move cursor to down window' },
      { '<C-k>', cmdstr([[lua require("smart-splits").move_cursor_up()]]),    desc = 'Move cursor to up window' },
      { '<C-l>', cmdstr([[lua require("smart-splits").move_cursor_right()]]), desc = 'Move cursor to right window' },
    },
    dependencies = {
      'kwkarlwang/bufresize.nvim',
    },
    build = "./kitty/install-kittens.bash",
    config = function()
      local splits = require("smart-splits")

      splits.setup({
        -- Ignored filetypes (only while resizing)
        ignored_filetypes = {
          'nofile',
          'quickfix',
          'prompt',
          'qf',
        },
        -- Ignored buffer types (only while resizing)
        ignored_buftypes = { 'nofile', 'NvimTree', },
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
        log_level = "error",
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
          buftype = vim.cfg.misc__buf_exclude
        },
      },
      selection_chars = "ABCDEFGHIJKLMNOPQRSTUVW"
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
        name = "harpoon_ui",
        immediate = true,
        callback = function()
          vim.cmd('hi! link HarpoonWindow NormalFloat')
          vim.cmd('hi! link HarpoonBorder NormalFloat')
        end
      })
    end,
    init = function()
      vim.g.harpoon_log_level = 'warn'
    end,
  }
})
