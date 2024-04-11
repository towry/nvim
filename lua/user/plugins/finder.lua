local plug = require('userlib.runtime.pack').plug
local keymap = require('userlib.runtime.keymap')
local cmd_modcall = keymap.cmd_modcall
local pickers_mod = 'userlib.telescope.pickers'
local fzf_mod = 'userlib.fzflua'
local au = require('userlib.runtime.au')

local BufferListKey = '<Localleader>,'

plug({
  'mangelozzi/rgflow.nvim',
  dependencies = {
    'pze/nvim-bqf',
  },
  opts = {
    default_trigger_mappings = false,
    default_ui_mappings = true,
    default_quickfix_mappings = true,
    -- you can override it with vim.b.grep_flags
    cmd_flags = '--smart-case --fixed-strings --no-fixed-strings -M 500',
    colors = {
      RgFlowInputPath = { link = 'NormalFloat' },
      RgFlowInputBg = { link = 'NormalFloat' },
      RgFlowInputFlags = { link = 'NormalFloat' },
      RgFlowInputPattern = { link = 'NormalFloat' },
    },
  },
  init = function()
    vim.api.nvim_create_user_command(
      'Rgflow',
      vim.schedule_wrap(function()
        require('rgflow').open(nil, vim.b.grep_flags or nil, safe_cwd(), {})
      end),
      { nargs = 0, desc = 'Open RgFlow UI' }
    )
  end,
  keys = {
    {
      '<localleader>fg',
      function()
        require('rgflow').open(nil, vim.b.grep_flags or nil, vim.cfg.runtime__starts_cwd, {
          custom_start = function(pattern, flags, path)
            require('userlib.fzflua').grep({ cwd = path, query = pattern, rg_opts = flags })
          end,
        })
      end,
      desc = 'Grep search in all project',
    },
    {
      '<localleader>fs',
      function()
        require('rgflow').open(nil, vim.b.grep_flags or nil, vim.uv.cwd(), {
          custom_start = function(pattern, flags, path)
            require('userlib.fzflua').grep({ cwd = path, query = pattern, rg_opts = flags })
          end,
        })
      end,
      desc = 'Grep search current project',
    },
    {
      '<localleader>fr',
      '<cmd>lua require("rgflow").open_again()<cr>',
      desc = 'Open rg flow with previous pattern',
    },
    -- open_cword
    {
      '<localleader>fw',
      function()
        require('rgflow').open(vim.fn.expand('<cword>'), vim.b.grep_flags or nil, vim.t.Cwd or vim.uv.cwd(), {
          custom_start = function(pattern, flags, path)
            require('userlib.fzflua').grep({ cwd = path, query = pattern, rg_opts = flags })
          end,
        })
      end,
      desc = 'Open rg flow with current word',
    },
    {
      '<localleader>fs',
      function()
        local utils = require('rgflow.utils')
        local content = utils.get_visual_selection(vim.fn.mode())
        local first_line = utils.get_first_line(content)
        -- Exit visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'x', true)
        require('rgflow').open(first_line, vim.b.grep_flags or nil, vim.t.Cwd or vim.uv.cwd(), {
          custom_start = function(pattern, flags, path)
            require('userlib.fzflua').grep({ cwd = path, query = pattern, rg_opts = flags })
          end,
        })
      end,
      desc = 'Open rg flow with visual selection',
      mode = { 'v', 'x' },
    },
    {
      '<leader>sgg',
      function()
        require('rgflow').open(nil, vim.b.grep_flags or nil, vim.uv.cwd(), {})
      end,
      desc = 'Open Rgflow',
    },
    {
      '<leader>ss',
      function()
        require('rgflow').open(nil, vim.b.grep_flags or nil, vim.uv.cwd(), {})
      end,
      desc = 'Open Rgflow',
    },
    {
      '<localleader>fx',
      '<cmd>lua require("rgflow").abort()<cr>',
      desc = 'Abort rg flow',
    },
    {
      '<leader>sgS',
      '<cmd>lua require("rgflow").print_status()<cr>',
      desc = 'Print rg flow status',
    },
    {
      '<leader>sgh',
      '<cmd>lua require("rgflow").show_rg_help()<cr>',
      desc = 'Show rg help in float window',
    },
  },
})

plug({
  enabled = true,
  'stevearc/oil.nvim',
  lazy = not vim.cfg.runtime__starts_in_buffer,
  event = { 'TabEnter' },
  cmd = 'Oil',
  opts = {
    default_file_explorer = true,
    columns = {
      -- 'icon',
    },
    keymaps = {
      ['g?'] = 'actions.show_help',
      ['<CR>'] = 'actions.select',
      ['<C-v>'] = 'actions.select_vsplit',
      ['<C-x>'] = 'actions.select_split',
      ['<C-t>'] = 'actions.select_tab',
      ['<C-p>'] = 'actions.preview',
      ['<C-c>'] = 'actions.close',
      ['<C-r>'] = 'actions.refresh',
      ['mv'] = function()
        require('userlib.mini.visits').list_oil_folders_in_cwd(vim.cfg.runtime__starts_cwd)
      end,
      ['md'] = function()
        -- remove all oil visited paths
        local visits = require('mini.visits')
        visits.remove_label('oil-folder-visited', nil, vim.cfg.runtime__starts_cwd)
        visits.write_index()
      end,
      ['mm'] = function()
        local oil = require('oil')
        local lcwd = oil.get_current_dir()
        local visits = require('mini.visits')
        visits.add_label('oil-folder-visited', lcwd, vim.cfg.runtime__starts_cwd)
        visits.write_index()
      end,
      ['M'] = function()
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
          require('userlib.mini.clue.folder-action').open(folder)
        else
          require('userlib.hydra.file-action').open(file, 0)
        end
      end,
      ['Y'] = 'actions.copy_entry_path',
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
    skip_confirm_for_simple_edits = true,
    delete_to_trash = false,
    view_options = {},
    lsp_file_methods = {
      autosave_changes = 'unmodified',
    },
    float = {
      padding = 4,
      border = vim.cfg.ui__float_border,
      win_options = {
        winblend = 0,
        -- statuscolumn = '',
        colorcolumn = '',
      },
    },
  },
  keys = {
    {
      '<leader>fO',
      function()
        if vim.bo.buftype ~= '' then
          return
        end
        require('oil').open(vim.uv.cwd())
      end,
      desc = 'Open oil(BUF) file browser in cwd',
    },
    {
      '-',
      function()
        if vim.bo.buftype ~= '' then
          return
        end
        require('oil').open()
      end,
      desc = 'Open oil file browser(buf) relative to current buffer',
    },
    {
      '_',
      function()
        if vim.bo.buftype ~= '' then
          return
        end
        require('oil').open_float()
      end,
      desc = 'Open oil file browser(buf|float) relative to current buffer',
    },
  },
  init = function()
    au.define_autocmd('BufWinEnter', {
      group = '_oil_change_cwd',
      pattern = 'oil:///*',
      callback = function()
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
    { keymap.super('l'), '<cmd>AerialToggle<cr>', desc = 'Symbols outline' },
  },
  cmd = { 'AerialToggle', 'AerialOpen', 'AerialClose' },
  opts = {
    backends = {
      ['_'] = { 'treesitter', 'lsp', 'man', 'markdown' },
      typescript = { 'treesitter', 'lsp' },
      typescriptreact = { 'treesitter', 'lsp' },
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
      placement = 'edge',
      -- When the symbols change, resize the aerial window (within min/max constraints) to fit
      resize_to_content = true,
      -- Preserve window size equality with (:help CTRL-W_=)
      preserve_equality = true,
    },
    -- global, window
    attach_mode = 'window',
    --- unfocus
    --- switch_buffer
    --- unsupported
    close_automatic_events = {
      'unsupported',
      'switch_buffer',
    },
    -- see :help SymbolKind
    filter_kind = {
      'Module',
      'Field',
      'Constant',
      'Enum',
      'EnumMember',
      'Event',
      -- 'Variable',
      'Operator',
      'TypeParameter',
      'Type',
      'Class',
      'Constructor',
      'Enum',
      'Function',
      'Interface',
      'Method',
      'Struct',
    },
    autojump = false,
    close_on_select = true,
    highlight_on_hover = true,
    show_guides = true,
    update_events = 'InsertLeave',
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
    get_highlight = function(symbol, _)
      if symbol.scope == 'private' then
        return 'AerialPrivate'
      end
    end,
  },
  config = function(_, opts)
    require('aerial').setup(opts)
  end,
})

local enable_oxi = false
plug({
  'nvim-pack/nvim-spectre',
  opts = {
    color_devicons = true,
    open_cmd = 'noswapfile tabnew',
    live_update = false,
    is_insert_mode = false,
    is_open_target_win = true,
  },
  build = function(plugin)
    if vim.fn.executable('cargo') == 1 and enable_oxi then
      local cwd = plugin.dir
      vim.cmd(string.format('tabe term://%s//%s', cwd, './build.sh;'))
    end
  end,
  cmd = { 'Spectre' },
  config = function(_, opts)
    require('spectre').setup(vim.tbl_extend('force', opts, {
      default = {
        replace = {
          cmd = enable_oxi and vim.fn.executable('cargo') == 1 and 'oxi' or 'sed',
        },
      },
    }))
  end,
  keys = {
    {
      '<leader>sp',
      function()
        require('spectre').open_visual()
      end,
      desc = 'Open Search and replace panel',
    },
    {
      '<leader>sP',
      function()
        local path = vim.fn.fnameescape(vim.fn.expand('%:p:.'))
        if vim.uv.os_uname().sysname == 'Windows_NT' then
          path = vim.fn.substitute(path, '\\', '/', 'g')
        end
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
  cond = not vim.cfg.runtime__starts_as_gittool,
  cmd = { 'Telescope' },
  keys_disable = {
    {
      '<leader>fb',
      cmd_modcall(pickers_mod, 'curbuf()'),
      desc = 'Fuzzy search in current buffer',
    },
    {
      BufferListKey,
      cmd_modcall(pickers_mod, 'buffers_or_recent()'),
      desc = 'List Buffers',
    },
    {
      '<leader>g/',
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
      '<leader>fF',
      cmd_modcall(pickers_mod, 'project_files({default_text = vim.fn.expand("<cword>")})'),
      desc = 'Open Project files with current word',
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
      '<localleader><Tab>',
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
      '<leader>fg',
      function()
        require('userlib.telescope.live_grep_call')({
          cwd = vim.cfg.runtime__starts_cwd,
        })
      end,
      desc = 'Grep search in all projects',
    },
    {
      '<leader>fs',
      cmd_modcall('userlib.telescope.live_grep_call', '()'),
      desc = 'Grep search in project',
    },
    {
      '<leader>fs',
      cmd_modcall('telescope-live-grep-args.shortcuts', 'grep_visual_selection()'),
      desc = 'Grep search on selection in project',
      mode = { 'v', 'x' },
    },
    {
      '<leader>fw',
      cmd_modcall('telescope-live-grep-args.shortcuts', 'grep_word_under_cursor()'),
      desc = 'Grep search on selection in project',
    },
    {
      '<leader>g.',
      '<cmd>Telescope git_bcommits<cr>',
      desc = 'Show commits for current buffer with diff preview',
    },
    {
      '<leader>fj',
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
      keys = {
        { '<leader>fz', ':lua require("telescope").extensions.zoxide.list()<cr>', desc = 'zoxide', silent = true },
      },
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
        borderchars = require('userlib.telescope.borderchars').dropdown_borderchars_default[1],
        wrap_results = false,
        --- give some opacity so we can see the window picker marks.
        winblend = 10,
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
          width = 0.90,
          -- prompt_position = 'top',
          horizontal = {
            preview_cutoff = 20,
          },
          vertical = {
            preview_cutoff = 0,
            width = 0.98,
          },
          flex = {},
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
        file_sorter = require('telescope.sorters').get_fuzzy_file,
        -- prompt_prefix = '',
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
              if vim.fn.mode() == 'n' then
                return
              end
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gEldEa', true, true, true), 'n', false)
            end,
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<C-s>'] = actions.cycle_previewers_next,
            ['<C-a>'] = actions.cycle_previewers_prev,
            ['<C-h>'] = function()
              if vim.fn.mode() == 'n' then
                return
              end
              -- jump between WORD
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gEa', true, true, true), 'n', false)
            end,
            ['<C-l>'] = function()
              if vim.fn.mode() == 'n' then
                return
              end
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
      pickers = {},
      extensions = {
        file_browser = {
          use_fd = true,
          mappings = {
            i = {
              ['<CR>'] = function(prompt_buf)
                local entry_path = action_state.get_selected_entry().Path
                local new_cwd = entry_path:is_dir() and entry_path:absolute() or entry_path:parent():absolute()

                actions.close(prompt_buf)
                require('userlib.mini.clue.folder-action').open(new_cwd)
              end,
            },
          },
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
        live_grep_args = {
          disable_coordinates = true,
          auto_quoting = true, -- enable/disable auto-quoting
          layout_strategy = 'vertical',
          layout_config = {
            width = 0.95,
            mirror = false,
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
              ['/'] = function()
                vim.cmd('startinsert')
              end,
            },
          },
        },
        zoxide = {
          --- https://github.com/jvgrootveld/telescope-zoxide
          prompt_title = 'Zz...',
          mappings = {
            default = {
              after_action = function(selection)
                print('Update to (' .. selection.z_score .. ') ' .. selection.path)
              end,
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

plug({
  'echasnovski/mini.visits',
  event = 'User LazyUIEnterOncePost',
  keys = {
    {
      '<leader>pv',
      -- BufferListKey,
      '<cmd>lua require("userlib.mini.visits").select_by_cwd(vim.cfg.runtime__starts_cwd)<cr>',
      desc = 'Show current cwd visits',
    },
    --- marks as m also create harpoon mark.
    {
      'mm',
      function()
        local visits = require('mini.visits')
        vim.b[0].is_harpoon = true
        visits.add_label('harpoon', nil, vim.cfg.runtime__starts_cwd)
        visits.write_index()
      end,
      silent = false,
      desc = 'Add to visits',
    },
    {
      'mM',
      function()
        vim.b[0].is_harpoon = false
        local visits = require('mini.visits')
        visits.remove_label('harpoon', nil, vim.cfg.runtime__starts_cwd)
        visits.write_index()
      end,
      silent = false,
      desc = 'Remove from visits',
    },
    {
      '<localleader>h',
      function()
        require('userlib.mini.visits').select_by_cwd(vim.cfg.runtime__starts_cwd, {
          filter = 'harpoon',
        })
      end,
      desc = 'List harpoon visits',
    },
    {
      '<leader>ph',
      function()
        require('userlib.mini.visits').select_by_cwd(vim.cfg.runtime__starts_cwd, {
          filter = 'harpoon',
        })
      end,
      desc = 'List harpoon visits',
    },
    {
      '<leader>pp',
      function()
        require('userlib.mini.visits').list_projects_in_cwd(vim.cfg.runtime__starts_cwd)
      end,
      desc = 'List projects in cwd',
    },
    {
      '<leader>pa',
      function()
        require('userlib.mini.visits').add_project(vim.uv.cwd(), vim.cfg.runtime__starts_cwd)
      end,
      desc = 'Add project',
    },
    {
      '<leader>pP',
      function()
        require('mini.visits').write_index()
      end,
      desc = 'Write index',
    },
  },
  opts = function()
    return {
      store = {
        autowrite = true,
      },
      track = {
        event = 'BufEnter',
        delay = 1000,
      },
    }
  end,
  config = function(_, opts)
    require('mini.visits').setup(opts)
  end,
})

plug({
  url = 'https://gitlab.com/ibhagwan/fzf-lua',
  -- 'ibhagwan/fzf-lua',
  -- 'pze/fzf-lua',
  dev = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  cmd = 'FzfLua',
  event = 'User LazyUIEnterOncePost',
  keys = {
    {
      '<localleader>:',
      ':FzfLua commands<cr>',
      desc = 'Command panel',
      silent = true,
    },
    {
      '<localleader>,',
      ':FzfLua<cr>',
      desc = 'Fzf',
      silent = true,
    },
    {
      '<C-x><C-e>',
      function()
        require('userlib.snippets.luasnip').fzf_complete_snippet()
      end,
      mode = { 'i' },
      desc = 'Complete snippets',
    },
    {
      '<leader>fb',
      cmd_modcall('fzf-lua', [[grep_curbuf({ cwd_header = true })]]),
      desc = 'Fuzzy search in current buffer',
    },
    {
      '<leader>fc',
      [[:FzfLua changes<cr>]],
      desc = 'Fzf search in changes with opened buffers',
    },
    {
      BufferListKey,
      cmd_modcall(fzf_mod, 'buffers_or_recent(false)'),
      nowait = true,
      desc = 'List Buffers',
    },
    {
      '<leader>ff',
      cmd_modcall(fzf_mod, [[files({ cwd_header = true })]]),
      desc = 'Project find files',
    },
    {
      '<leader>g/',
      cmd_modcall(fzf_mod, [[git_branches()]]),
      desc = 'Git branches',
    },
    {
      '<leader>fF',
      cmd_modcall(fzf_mod, 'files({query = vim.fn.expand("<cword>")})'),
      desc = 'Open Project files with current word',
    },

    {
      '<leader>fe',
      cmd_modcall(fzf_mod, 'files({cwd=vim.cfg.runtime__starts_cwd})'),
      desc = 'Open find all files',
    },
    {
      '<leader>fr',
      cmd_modcall('fzf-lua', [[builtin({ query = 'resume' })]]),
      desc = 'Resume fzf',
    },
    {
      '<localleader><Tab>',
      cmd_modcall(fzf_mod, 'buffers_or_recent(true)'),
      nowait = true,
      desc = 'Open recent files',
    },
    {
      '<leader>fo',
      function()
        require('userlib.fzflua').folders({
          cwd = vim.cfg.runtime__starts_cwd,
          cwd_header = true,
        })
      end,
      desc = 'Find all folders',
    },
    {
      '<leader>fl',
      function()
        require('userlib.fzflua').folders({
          cwd = require('userlib.runtime.utils').get_root(),
        })
      end,
      desc = 'Find project folders',
    },
    {
      '<leader>fg',
      cmd_modcall(fzf_mod, [[ grep({ cwd = vim.cfg.runtime__starts_cwd }, true) ]]),
      desc = 'Grep search in all projects',
    },
    {
      '<leader>fg',
      cmd_modcall(fzf_mod, [[grep_visual({ cwd = vim.cfg.runtime__starts_cwd })]]),
      desc = 'Grep search on selection in all projects',
      mode = { 'v', 'x' },
    },
    {
      '<leader>fs',
      cmd_modcall(fzf_mod, [[ grep({ cwd = vim.t.Cwd or vim.uv.cwd(), cwd_header = true }, true) ]]),
      desc = 'Grep search in project',
    },
    {
      '<leader>fs',
      cmd_modcall(fzf_mod, [[ grep_visual({ cwd = vim.t.Cwd or vim.uv.cwd() }) ]]),
      desc = 'Grep search on selection in project',
      mode = { 'v', 'x' },
    },
    {
      '<leader>fw',
      cmd_modcall(fzf_mod, [[grep({ cwd = vim.t.Cwd or vim.uv.cwd(), query = vim.fn.expand("<cword>") }, true)]]),
      desc = 'Grep search word in current project',
    },
    {
      '<leader>fW',
      cmd_modcall(fzf_mod, [[grep({ cwd = vim.cfg.runtime__starts_cwd, query = vim.fn.expand("<cword>") }, true)]]),
      desc = 'Grep search word in all project',
    },
    {
      '<leader>fj',
      cmd_modcall('fzf-lua', [[jumps()]]),
      desc = 'Show jumplist',
    },
  },
  config = function()
    local actions = require('fzf-lua.actions')
    local local_actions = require('userlib.fzflua.actions')
    local fzflua = require('fzf-lua')
    -- https://github.com/ibhagwan/fzf-lua?tab=readme-ov-file#default-options
    fzflua.setup({
      'max-perf',
      winopts = {
        on_create = function()
          require('userlib.fzflua.on_attach')
        end,
        border = 'single',
        fullscreen = true,
        preview = {
          delay = 150,
          scrollbar = false,
          default = 'builtin',
          wrap = 'wrap',
          horizontal = 'right:45%',
          vertical = 'down:40%',
          winopts = {
            cursorlineopt = 'line',
            foldcolumn = 0,
          },
        },
      },
      keymap = {
        fzf = {},
      },
      actions = {
        files = {
          ['default'] = actions.file_edit_or_qf,
          ['ctrl-o'] = local_actions.files_open_in_window,
          ['ctrl-s'] = actions.file_split,
          ['ctrl-v'] = actions.file_vsplit,
          ['ctrl-t'] = actions.file_tabedit,
          ['alt-q'] = actions.file_sel_to_qf,
          ['alt-l'] = actions.file_sel_to_ll,
          ['ctrl-g'] = actions.toggle_ignore,
        },
        buffers = {
          ['default'] = local_actions.buffers_open_default,
          ['ctrl-o'] = local_actions.buffers_open_in_window,
          ['ctrl-s'] = actions.buf_split,
          ['ctrl-v'] = actions.buf_vsplit,
          ['ctrl-t'] = actions.buf_tabedit,
        },
      },
      -- options are sent as `<left>=<right>`
      -- set to `false` to remove a flag
      -- set to '' for a non-value flag
      -- for raw args use `fzf_args` instead
      fzf_opts = {
        ['--ansi'] = '',
        ['--keep-right'] = true,
        ['--info'] = 'inline',
        ['--height'] = '100%',
        ['--layout'] = 'reverse',
        ['--border'] = 'none',
        ['--cycle'] = '',
      },
      previewers = {
        builtin = {
          syntax_limit_l = 8000,
          syntax_limit_b = 1024 * 50,
          limit_b = 1024 * 50,
        },
      },
    })

    local enable_fzf_select = vim.cfg.ui__input_select_provider == 'fzf-lua'

    if not enable_fzf_select then
      return
    end

    fzflua.register_ui_select({
      winopts = {
        fullscreen = false,
        height = 0.6,
        width = 0.75,
      },
      fzf_opts = {
        ['--keep-right'] = true,
        ['--delimiter'] = '[BEGIN{FS="."}]',
        -- ['--delimiter'] = '[\\.]',
        ['--with-nth'] = '2..',
      },
    })
  end,
})
