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
    }
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

  --- auto close buffer after a time.
  {
    'chrisgrieser/nvim-early-retirement',
    enabled = false,
    config = function()
      require('early-retirement').setup({
        retirementAgeMins = 15,
        ignoreAltFile = true,
        minimumBufferNum = 10,
        ignoreUnsavedChangesBufs = true,
        ignoreSpecialBuftypes = true,
        ignoreVisibleBufs = true,
        ignoreUnloadedBufs = false,
        notificationOnAutoClose = true,
      })
    end,
    init = function()
      local loaded = false
      au.define_autocmds({
        {
          "User",
          {
            group = "_plugin_load_early_retirement",
            pattern = au.user_autocmds.FileOpened,
            once = true,
            callback = function()
              if loaded then
                return
              end
              loaded = true
              vim.defer_fn(function()
                vim.cmd("Lazy load nvim-early-retirement")
              end, 2000)
            end,
          }
        }
      })
    end,
  },

  ----- file
  {
    -- Convenience file operations for neovim, written in lua.
    "chrisgrieser/nvim-genghis",
    init = function()
      require('userlib.legendary').pre_hook('setup_lg_genghis_files_ops', function(lg)
        local genghis = require('genghis')

        lg.funcs({
          {
            description = 'File: Copy file path',
            genghis.copyFilepath,
          },
          {
            description = 'File: Change file mode',
            genghis.chmodx,
          },
          {
            description = 'File: Rename file',
            genghis.renameFile,
          },
          {
            description = 'File: Move and rename file',
            genghis.moveAndRenameFile,
          },
          {
            description = 'File: Create new file',
            genghis.createNewFile,
          },
          {
            description = 'File: Duplicate file',
            genghis.duplicateFile,
          },
          {
            description = 'File: Trash file',
            function()
              genghis.trashFile()
            end,
          },
          {
            description = 'File: Move selection to new file',
            genghis.moveSelectionToNewFile,
          }
        })
      end)
    end
  },

  ----- grapple and portal
  {
    'cbochs/portal.nvim',
    cmd = { 'Portal' },
    keys = {
      {
        '<M-o>',
        function()
          local builtins = require('portal.builtin')
          local opts = {
            direction = 'backward',
            max_results = 2,
          }

          local jumplist = builtins.jumplist.query(opts)
          -- local harpoon = builtins.harpoon.query(opts)
          local grapples = builtins.grapple.query(opts)

          require('portal').tunnel({ jumplist, grapples })
        end,
        desc = 'Portal jump backward',
      },
      {
        '<M-i>',
        function()
          local builtins = require('portal.builtin')
          local opts = {
            direction = 'forward',
            max_results = 2,
          }

          local jumplist = builtins.jumplist.query(opts)
          -- local harpoon = builtins.harpoon.query(opts)
          local grapples = builtins.grapple.query(opts)

          require('portal').tunnel({ jumplist, grapples })
        end,
        desc = 'Portal jump forward',
      }
    },
    dependencies = {
      'cbochs/grapple.nvim',
    },
    config = function()
      -- local nvim_set_hl = vim.api.nvim_set_hl
      require('portal').setup({
        log_level = 'error',
        window_options = {
          relative = "cursor",
          width = 40,
          height = 2,
          col = 1,
          focusable = false,
          border = "rounded",
          noautocmd = true,
        }
      })

      -- FIXME: colors.
      -- nvim_set_hl(0, 'PortalBorderForward', { fg = colors.portal_border_forward })
      -- nvim_set_hl(0, 'PortalBorderNone', { fg = colors.portal_border_none })
    end,
  },
  {
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
  ---- monorepo
  {
    "imNel/monorepo.nvim",
    keys = {
      {
        '<leader>fm',
        [[<cmd>lua require("telescope").extensions.monorepo.monorepo()<cr>]],
        desc = 'Manage monorepo',
      },
      {
        '<leader>f$',
        [[<cmd>lua require("monorepo").toggle_project()<cr>]],
        desc = 'Toggle cwd as project'
      },
    },
    opts = {
      autoload_telescope = true,
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
            '<localleader>p',
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
            "~/.cargo/*",
            "~/.local/*",
            "~/.cache/*",
            "/dist/*",
            "/node_modules/*",
            "/.pnpm/*"
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
          scope_chdir = 'win',
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
        autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
        max_path_length = 80,            -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
      })
    end,
  },

  {
    'kwkarlwang/bufresize.nvim',
    config = true,
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
    'folke/trouble.nvim',
    cmd = { 'TroubleToggle', 'Trouble' },
    keys = {
      {
        '<leader>cd', '<cmd>TroubleToggle document_diagnostics<cr>', desc = 'Toggle document diagnostics'
      },
      {
        '<leader>wd', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = 'Toggle workspace diagnostics'
      },
      {
        '<leader>tq',
        function()
          if require('trouble').is_open() then
            require('trouble').close()
            return
          end
          require('userlib.runtime.qf').toggle_qf()
        end,
        desc = 'Toggle Quickfix'
      },
      {
        '<leader>tl',
        function()
          require('userlib.runtime.qf').toggle_loc()
        end,
        desc = 'Toggle loclist',
      }
    },
    config = function()
      local icons = require('userlib.icons')
      require('trouble').setup({
        position = 'bottom',           -- position of the list can be: bottom, top, left, right
        height = 10,                   -- height of the trouble list when position is top or bottom
        width = 50,                    -- width of the list when position is left or right
        icons = true,                  -- use devicons for filenames
        mode = 'document_diagnostics', -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
        fold_open = '',             -- icon used for open folds
        fold_closed = '',           -- icon used for closed folds
        group = true,                  -- group results by file
        padding = true,                -- add an extra new line on top of the list
        action_keys = {
          -- key mappings for actions in the trouble list
          -- map to {} to remove a mapping, for example:
          -- close = {},
          close = 'q',                     -- close the list
          cancel = '<esc>',                -- cancel the preview and get back to your last window / buffer / cursor
          refresh = 'r',                   -- manually refresh
          jump = { '<cr>', '<tab>' },      -- jump to the diagnostic or open / close folds
          open_split = { '<c-x>' },        -- open buffer in new split
          open_vsplit = { '<c-v>' },       -- open buffer in new vsplit
          open_tab = { '<c-t>' },          -- open buffer in new tab
          jump_close = { 'o' },            -- jump to the diagnostic and close the list
          toggle_mode = 'm',               -- toggle between "workspace" and "document" diagnostics mode
          toggle_preview = 'P',            -- toggle auto_preview
          hover = 'K',                     -- opens a small popup with the full multiline message
          preview = 'p',                   -- preview the diagnostic location
          close_folds = { 'zM', 'zm' },    -- close all folds
          open_folds = { 'zR', 'zr' },     -- open all folds
          toggle_fold = { 'zA', 'za' },    -- toggle fold of current file
          previous = 'k',                  -- preview item
          next = 'j',                      -- next item
        },
        indent_lines = true,               -- add an indent guide below the fold icons
        auto_open = false,                 -- automatically open the list when you have diagnostics
        auto_close = false,                -- automatically close the list when you have no diagnostics
        auto_preview = true,               -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
        auto_fold = false,                 -- automatically fold a file trouble list at creation
        auto_jump = { 'lsp_definitions' }, -- for the given modes, automatically jump if there is only a single result
        signs = {
          -- icons / text used for a diagnostic
          error = icons.errorOutline,
          warning = icons.warningTriangleNoBg,
          hint = icons.lightbulbOutline,
          information = icons.infoOutline,
        },
        use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
      })
    end,
    init = function()
      require('userlib.legendary').pre_hook('setup_trouble_lg', function(lg)
        lg.commands({
          -- troubles.
          {
            ':TodoTrouble',
            description = 'Show todo in trouble',
          },
          {
            [[:exe "TodoTrouble cwd=" . expand("%:p:h")]],
            description = 'Show todo in trouble within current file directory',
          },
        })
      end)
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
    'pze/harpoon',
    dev = false,
    event = 'User LazyUIEnterOncePost',
    keys = {
      {
        '<localleader>h',
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
      {
        '<localleader>m',
        '<cmd>lua require("harpoon.ui").nav_next()<cr>',
        desc = 'Harpoon next',
        silent = false,
      },
      {
        '<localleader>M',
        '<cmd>lua require("harpoon.ui").nav_prev()<cr>',
        desc = 'Harpoon prev',
        silent = false,
      }
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
        get_project_key = function()
          return vim.cfg.runtime__starts_cwd
        end,
      }
    end,
    config = function(_, opts)
      require('harpoon').setup(opts)
    end,
    init = function()
      vim.g.harpoon_log_level = 'warn'
    end,
  }
})
