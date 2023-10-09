local plug = require('userlib.runtime.pack').plug
local keymap = require('userlib.runtime.keymap')
-- local cmdstr = keymap.cmdstr
local cmd_modcall = keymap.cmd_modcall
local pickers_mod = 'userlib.telescope.pickers'
local au = require('userlib.runtime.au')

plug({
  'kyoh86/vim-ripgrep',
  event = 'User LazyUIEnterOncePost',
  init = function()
    --- https://github.dev/qalshidi/vim-bettergrep
    -- abbr rg to Rg
    vim.cmd([[cnoreabbrev <expr> rg (getcmdtype() ==# ':' && getcmdline() ==# 'rg')  ? 'Rg' : 'rg']])
    vim.cmd([[command! -nargs=+ -complete=file Rg :call ripgrep#search(<q-args>)]])
  end,
})

plug({
  enabled = true,
  'stevearc/oil.nvim',
  lazy = not vim.cfg.runtime__starts_in_buffer,
  event = { 'TabEnter' },
  opts = {
    default_file_explorer = true,
    keymaps = {
      ['g?'] = 'actions.show_help',
      ['<CR>'] = 'actions.select',
      ['<C-v>'] = 'actions.select_vsplit',
      ['<C-x>'] = 'actions.select_split',
      ['<C-t>'] = 'actions.select_tab',
      ['<C-p>'] = 'actions.preview',
      ['<C-c>'] = 'actions.close',
      ['<C-r>'] = 'actions.refresh',
      ['<C-o>'] = function()
        local oil = require('oil')
        -- type: file|directory
        local current = require('oil').get_cursor_entry()
        local lcwd = oil.get_current_dir()
        local file, folder = nil, nil
        if not current or current.type == 'directory' then
          file = nil
          folder = lcwd .. current.name
        elseif current.type == 'file' then
          folder = nil
          file = lcwd .. current.name
        end

        if folder then
          require('userlib.hydra.folder-action').open(folder, 0)
        else
          require('userlib.hydra.file-action').open(file, 0)
        end
      end,
      ['y'] = 'actions.copy_entry_path',
      ['-'] = 'actions.parent',
      ['_'] = function()
        if vim.w.oil_lcwd ~= nil then
          require('oil').open(vim.w.oil_lcwd)
          vim.w.oil_lcwd = nil
        else
          vim.w.oil_lcwd = require('oil').get_current_dir()
          --- toggle with current and project root.
          require('oil').open(require('userlib.runtime.utils').get_root())
        end
      end,
      ['`'] = 'actions.cd',
      ['~'] = 'actions.tcd',
      ['g.'] = 'actions.toggle_hidden',
    },
    use_default_keymaps = false,
    delete_to_trash = false,
    -- is_hidden_file = function(name, bufnr)
    --   return vim.startswith(name, ".")
    -- end,
    float = {
      padding = 3,
      border = vim.cfg.ui__float_border,
      win_options = {
        winblend = 10,
      },
    },
  },
  keys = {
    -- {
    --   '<leader>fo',
    --   function() require('oil').open(vim.cfg.runtime__starts_cwd) end,
    --   desc = 'Open oil(Root) file browser',
    -- },
    {
      '<leader>fO',
      function() require('oil').open(require('userlib.runtime.utils').get_root()) end,
      desc = 'Open oil(BUF) file browser',
    },
    {
      '-',
      function() require('oil').open() end,
      desc = 'Open oil file browser(buf)',
    },
    {
      '_',
      function() require('oil').open_float() end,
      desc = 'Open oil file browser(buf|float)',
    },
  },
  init = function()
    au.define_autocmd('BufWinEnter', {
      group = '_oil_change_cwd',
      pattern = 'oil:///*',
      callback = function(ctx)
        local cwd = require('oil').get_current_dir()
        require('userlib.runtime.utils').change_cwd(cwd, 'lcd', true)
      end,
    })
  end,
})

plug({
  'stevearc/aerial.nvim',
  keys = {
    { '<leader>/o', '<cmd>AerialToggle<cr>', desc = 'Symbols outline' },
    -- <CMD-l> open the outline.
    { '<D-l>', '<cmd>AerialToggle<cr>', desc = 'Symbols outline' },
  },
  cmd = { 'AerialToggle', 'AerialOpen', 'AerialClose' },
  opts = {
    backends = {
      ['_'] = { 'lsp', 'man', 'markdown' },
      typescript = { 'lsp' },
      typescriptreact = { 'lsp' },
    },
    layout = {
      -- These control the width of the aerial window.
      -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_width and max_width can be a list of mixed types.
      -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
      max_width = 0.5,
      width = nil,
      min_width = 30,
      -- key-value pairs of window-local options for aerial window (e.g. winhl)
      win_opts = {},
      -- Determines the default direction to open the aerial window. The 'prefer'
      -- options will open the window in the other direction *if* there is a
      -- different buffer in the way of the preferred direction
      -- Enum: prefer_right, prefer_left, right, left, float
      default_direction = 'prefer_right',
      -- Determines where the aerial window will be opened
      --   edge   - open aerial at the far right/left of the editor
      --   window - open aerial to the right/left of the current window
      placement = 'window',
      -- When the symbols change, resize the aerial window (within min/max constraints) to fit
      resize_to_content = true,
      -- Preserve window size equality with (:help CTRL-W_=)
      preserve_equality = true,
    },
    -- global, window
    attach_mode = 'global',
    --- unfocus
    --- switch_buffer
    --- unsupported
    close_automatic_events = {},
    -- see :help SymbolKind
    filter_kind = {
      'Field',
      'Constant',
      'Enum',
      'EnumMember',
      'Event',
      'Variable',
      'Operator',
      'TypeParameter',
      'Type',
      'Class',
      'Constructor',
      'Enum',
      'Function',
      'Interface',
      'Module',
      'Method',
      'Struct',
    },
    autojump = true,
    close_on_select = true,
    highlight_on_hover = true,
    show_guides = true,
    ignore = {
      -- Ignore unlisted buffers. See :help buflisted
      unlisted_buffers = false,
      -- List of filetypes to ignore.
      filetypes = vim.cfg.misc__ft_exclude,
      -- Ignored buftypes.
      -- Can be one of the following:
      -- false or nil - No buftypes are ignored.
      -- "special"    - All buffers other than normal, help and man page buffers are ignored.
      -- table        - A list of buftypes to ignore. See :help buftype for the
      --                possible values.
      -- function     - A function that returns true if the buffer should be
      --                ignored or false if it should not be ignored.
      --                Takes two arguments, `bufnr` and `buftype`.
      buftypes = 'special',
      -- Ignored wintypes.
      -- Can be one of the following:
      -- false or nil - No wintypes are ignored.
      -- "special"    - All windows other than normal windows are ignored.
      -- table        - A list of wintypes to ignore. See :help win_gettype() for the
      --                possible values.
      -- function     - A function that returns true if the window should be
      --                ignored or false if it should not be ignored.
      --                Takes two arguments, `winid` and `wintype`.
      wintypes = 'special',
    },
    float = {
      -- Controls border appearance. Passed to nvim_open_win
      border = vim.cfg.ui__float_border,
    },
    lsp = {
      diagnostics_trigger_update = false,
      update_when_errors = false,
    },
  },
  config = function(_, opts)
    require('aerial').setup(opts)
    -- vim.api.nvim_set_hl(0, 'AerialPrivate', { default = true, italic = true })
  end,
})

plug({
  'nvim-pack/nvim-spectre',
  opts = {
    color_devicons = true,
    open_cmd = 'vnew',
    live_update = true,
    is_insert_mode = false,
    is_open_target_win = false,
  },
  cmd = { 'Spectre' },
  keys = {
    {
      '<leader>sp',
      function() require('spectre').open_visual() end,
      desc = 'Open Search and replace panel',
    },
    {
      '<leader>sP',
      function()
        local path = vim.fn.fnameescape(vim.fn.expand('%:p:.'))
        if vim.uv.os_uname().sysname == 'Windows_NT' then path = vim.fn.substitute(path, '\\', '/', 'g') end
        require('spectre').open({
          path = path,
          is_close = true,
          search_text = vim.fn.expand('<cword>'),
        })
      end,
      desc = 'Search and replace cword in current file',
    },
  },
})

plug({
  --- In the SSR float window you can see the placeholder
  --- search code, you can replace part of it with wildcards.
  --- A wildcard is an identifier starts with $, like $name.
  --- A $name wildcard in the search pattern will match any
  --- AST node and $name will reference it in the replacement.
  'cshuaimin/ssr.nvim',
  module = 'ssr',
  keys = {
    {
      '<leader>sr',
      '<cmd>lua require("ssr").open()<cr>',
      mode = { 'n', 'x' },
      desc = 'Replace with Treesitter structure(SSR)',
    },
  },
  opts = {
    border = vim.cfg.ui__float_border,
    min_width = 50,
    min_height = 5,
    max_width = 120,
    max_height = 25,
    keymaps = {
      close = 'q',
      next_match = 'n',
      prev_match = 'N',
      replace_confirm = '<cr>',
      replace_all = '<S-CR>',
    },
  },
})

plug({
  'nvim-telescope/telescope.nvim',
  cmd = { 'Telescope' },
  keys = {
    {
      '<leader>fb',
      cmd_modcall(pickers_mod, 'curbuf()'),
      desc = 'Fuzzy search in current buffer',
    },
    {
      '<Tab>',
      cmd_modcall(pickers_mod, 'buffers_or_recent()'),
      desc = 'List Buffers',
    },
    {
      '<leader>gb',
      function()
        require('userlib.ui.dropdown').select({
          items = {
            {
              label = 'Git branches',
              hint = 'local',
              'Telescope git_branches show_remote_tracking_branches=false',
            },
            {
              label = 'Git branches',
              hint = 'remotes',
              'Telescope git_branches',
            },
          },
        }, {
          prompt_title = 'Select action',
        })
      end,
      desc = 'Git branches',
    },
    {
      '<leader>ff',
      cmd_modcall(pickers_mod, 'project_files()'),
      desc = 'Open Project files',
    },
    {
      '<leader>fe',
      cmd_modcall(pickers_mod, 'project_files({use_all_files=false, cwd=vim.cfg.runtime__starts_cwd})'),
      desc = 'Open find all files',
    },
    {
      '<leader>fr',
      cmd_modcall('telescope.builtin', 'resume()'),
      desc = 'Resume telescope pickers',
    },
    {
      '<leader><Tab>',
      cmd_modcall(
        pickers_mod,
        [[project_files(require('telescope.themes').get_dropdown({ previewer = false, cwd_only = false, oldfiles = true, cwd = vim.cfg.runtime__starts_cwd }))]]
      ),
      desc = 'Open recent files',
    },
    {
      '<leader>fo',
      function()
        --- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/e03ff55962417b69c85ef41424079bb0580546ba/lua/telescope/_extensions/file_browser/actions.lua#L598
        require('telescope').extensions.file_browser.file_browser(require('telescope.themes').get_dropdown({
          files = false,
          use_fd = true,
          display_stat = false,
          hide_parent_dir = true,
          respect_gitignore = true,
          hidden = false,
          previewer = false,
          depth = 3,
          git_status = false,
          cwd = vim.cfg.runtime__starts_cwd,
          borderchars = require('userlib.telescope.borderchars').dropdown_borderchars_default,
        }))
      end,
      desc = 'Find all folders',
    },
    {
      '<leader>fl',
      function()
        --- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/e03ff55962417b69c85ef41424079bb0580546ba/lua/telescope/_extensions/file_browser/actions.lua#L598
        require('telescope').extensions.file_browser.file_browser(require('telescope.themes').get_dropdown({
          results_title = vim.t.cwd_short,
          files = false,
          use_fd = true,
          previewer = false,
          respect_gitignore = true,
          hidden = false,
          depth = 5,
          git_status = false,
          collapse_dirs = true,
          hide_parent_dir = true,
          display_stat = false,
          cwd = require('userlib.runtime.utils').get_root(),
        }))
      end,
      desc = 'Find project folders',
    },
    {
      '<leader>fs',
      function()
        require('userlib.telescope.live_grep_call')({
          cwd = vim.cfg.runtime__starts_cwd,
        })
      end,
      desc = 'Grep search in all projects',
    },
    {
      '<leader>fg',
      cmd_modcall('userlib.telescope.live_grep_call', '()'),
      desc = 'Grep search in project',
    },
    {
      '<leader>fg',
      cmd_modcall('telescope-live-grep-args.shortcuts', 'grep_visual_selection()'),
      desc = 'Grep search on selection in project',
      mode = { 'v', 'x' },
    },
    {
      '<leader>fG',
      cmd_modcall('telescope-live-grep-args.shortcuts', 'grep_word_under_cursor()'),
      desc = 'Grep search on selection in project',
    },
    {
      '<leader>g.',
      '<cmd>Telescope git_bcommits<cr>',
      desc = 'Show commits for current buffer with diff preview',
    },
    {
      '<D-\\>',
      '<cmd>Telescope jumplist fname_width=60 show_line=false<cr>',
      desc = 'Show jumplist',
    },
  },
  dependencies = {
    { 'nvim-lua/popup.nvim' },
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    {
      'tknightz/telescope-termfinder.nvim',
    },
    {
      'pze/telescope-file-browser.nvim',
      -- branch = 'feat/max-results',
      dev = false,
    },
    {
      'jvgrootveld/telescope-zoxide',
    },
  },
  config = function(_, opts)
    require('telescope').setup(opts)
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('live_grep_args')
    require('telescope').load_extension('termfinder')
    require('telescope').load_extension('zoxide')
    --- https://github.com/nvim-telescope/telescope-file-browser.nvim
    --- Telescope file_browser files=false
    require('telescope').load_extension('file_browser')
    au.do_useraucmd(au.user_autocmds.TelescopeConfigDone_User)

    -- colorscheme
    au.register_event(au.events.AfterColorschemeChanged, {
      name = 'telescope_ui',
      immediate = true,
      callback = function()
        vim.cmd('hi! link TelescopeNormal NormalFloat')
        vim.cmd('hi! link TelescopeBorder NormalFloat')
      end,
    })
  end,
  opts = function()
    -- local au = require('userlib.runtime.au')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local lga_actions = require('telescope-live-grep-args.actions')
    local icons = require('userlib.icons')

    local git_icons = {
      added = icons.gitAdd,
      changed = icons.gitChange,
      copied = '>',
      deleted = icons.gitRemove,
      renamed = '➡',
      unmerged = '‡',
      untracked = '?',
    }

    return {
      defaults = {
        border = true,
        borderchars = require('userlib.telescope.borderchars').dropdown_borderchars_default,
        wrap_results = false,
        --- give some opacity so we can see the window picker marks.
        winblend = 0,
        cache_picker = {
          num_pickers = 5,
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
        },
        layout_config = {
          prompt_position = 'top',
          horizontal = {
            preview_cutoff = 120,
          },
          bottom_pane = {
            preview_width = 0.4,
            -- When columns are less than this value, the preview will be disabled
            preview_cutoff = 10,
          },
        },
        -- generic_sorter = require('mini.fuzzy').get_telescope_sorter,
        ---@see https://github.com/nvim-telescope/telescope.nvim/issues/522#issuecomment-1107441677
        file_ignore_patterns = { 'node_modules/', '.turbo/', 'dist', '.git/' },
        path_display = { 'truncate' },
        layout_strategy = 'flex',
        -- layout_strategy = "vertical",
        file_sorter = require('telescope.sorters').get_fzy_sorter,
        prompt_prefix = '',
        color_devicons = true,
        initial_mode = 'insert',
        git_icons = git_icons,
        sorting_strategy = 'ascending',
        file_previewer = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
        mappings = {
          i = {
            --- used to move cursor forward.
            ['<C-f>'] = false,
            ['<S-BS>'] = function()
              --- delete previous W
              if vim.fn.mode() == 'n' then return end
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gEldEa', true, true, true), 'n', false)
            end,
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<C-s>'] = actions.cycle_previewers_next,
            ['<C-a>'] = actions.cycle_previewers_prev,
            ['<C-h>'] = function()
              if vim.fn.mode() == 'n' then return end
              -- jump between WORD
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gEa', true, true, true), 'n', false)
            end,
            ['<C-l>'] = function()
              if vim.fn.mode() == 'n' then return end
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>Ea', true, true, true), 'n', false)
            end,
            ['<ESC>'] = function(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              local prompt = picker:_get_prompt()
              if not prompt or #prompt <= 0 then
                actions.close(prompt_bufnr)
                return
              end
              vim.cmd('stopinsert')
            end,
            ['<C-ESC>'] = actions.close,
            ['<C-c>'] = function(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              picker:set_prompt('')
            end,
          },
          n = {
            ['<C-s>'] = actions.cycle_previewers_next,
            ['<C-a>'] = actions.cycle_previewers_prev,
            ['<C-h>'] = 'which_key',
          },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown({
            border = true,
            borderchars = require('userlib.telescope.borderchars').dropdown_borderchars_default,
            -- even more opts
          }),
        },
        file_browser = {
          use_fd = true,
          mappings = {
            i = {
              ['<CR>'] = function(prompt_buf)
                local entry_path = action_state.get_selected_entry().Path
                local new_cwd = entry_path:is_dir() and entry_path:absolute() or entry_path:parent():absolute()

                require('userlib.hydra.folder-action').open(new_cwd, prompt_buf)
              end,
            },
          },
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = false,
          override_file_sorter = false,
          case_mode = 'smart_case',
        },
        live_grep_args = {
          disable_coordinates = true,
          auto_quoting = true, -- enable/disable auto-quoting
          -- theme = "dropdown",
          -- layout_strategy = "bottom_pane",
          layout_config = {
            width = 0.9,
          },
          mappings = {
            -- extend mappings
            i = {
              ['<C-k>'] = lga_actions.quote_prompt(),
              ['<C-o>'] = function(prompt_bufnr)
                return require('userlib.telescope.picker_keymaps').open_selected_in_window(prompt_bufnr)
              end,
            },
            ['n'] = {
              -- your custom normal mode mappings
              ['/'] = function() vim.cmd('startinsert') end,
            },
          },
        },
        zoxide = {
          --- https://github.com/jvgrootveld/telescope-zoxide
          prompt_title = 'Zz...',
          mappings = {
            default = {
              after_action = function(selection) print('Update to (' .. selection.z_score .. ') ' .. selection.path) end,
            },
            -- ["<C-s>"] = {
            --   before_action = function(selection) print("before C-s") end,
            --   action = function(selection)
            --     vim.cmd.edit(selection.path)
            --   end
            -- },
            -- -- Opens the selected entry in a new split
            -- ["<C-v>"] = { action = z_utils.create_basic_command("split") },
          },
        },
      },
    }
  end,
})
