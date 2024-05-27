local plug = require('userlib.runtime.pack').plug
local keymap = require('userlib.runtime.keymap')
local cmd_modcall = keymap.cmd_modcall
local pickers_mod = 'userlib.telescope.pickers'
local fzf_mod = 'userlib.fzflua'
local au = require('userlib.runtime.au')

local BufferListKey = '<Localleader>,'

plug({
  'mangelozzi/rgflow.nvim',
  opts = {
    default_trigger_mappings = false,
    default_ui_mappings = true,
    default_quickfix_mappings = true,
    -- you can override it with vim.b.grep_flags
    cmd_flags = '--smart-case --no-fixed-strings --fixed-strings -M 500',
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
        require('rgflow').open(
          nil,
          vim.b.grep_flags or require('userlib.finder').get_grep_flags_with_glob(),
          vim.cfg.runtime__starts_cwd,
          {
            custom_start = function(pattern, flags, path)
              require('userlib.fzflua').grep({ cwd = path, query = pattern, rg_opts = flags })
            end,
          }
        )
      end,
      desc = 'Grep search in all project',
    },
    {
      '<localleader>fs',
      function()
        require('rgflow').open(
          nil,
          vim.b.grep_flags or require('userlib.finder').get_grep_flags_with_glob(),
          vim.uv.cwd(),
          {
            custom_start = function(pattern, flags, path)
              require('userlib.fzflua').grep({ cwd = path, query = pattern, rg_opts = flags })
            end,
          }
        )
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
        require('rgflow').open(
          vim.fn.expand('<cword>'),
          vim.b.grep_flags or require('userlib.finder').get_grep_flags_with_glob(),
          vim.t.Cwd or vim.uv.cwd(),
          {
            custom_start = function(pattern, flags, path)
              require('userlib.fzflua').grep({ cwd = path, query = pattern, rg_opts = flags })
            end,
          }
        )
      end,
      desc = 'Open rg flow with current word',
    },
    {
      '<localleader>fs',
      function()
        local first_line = Ty.buf_vtext()
        -- Exit visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'x', true)
        require('rgflow').open(
          first_line,
          vim.b.grep_flags or require('userlib.finder').get_grep_flags_with_glob(),
          vim.t.Cwd or vim.uv.cwd(),
          {
            custom_start = function(pattern, flags, path)
              require('userlib.fzflua').grep({ cwd = path, query = pattern, rg_opts = flags })
            end,
          }
        )
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
        require('rgflow').open(
          nil,
          vim.b.grep_flags or require('userlib.finder').get_grep_flags_with_glob(),
          vim.uv.cwd(),
          {}
        )
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
  'mikavilpas/yazi.nvim',
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      '<leader>-',
      function()
        require('yazi').yazi(nil, vim.uv.cwd())
      end,
      desc = 'Open the file manager',
    },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = false,
    -- what Neovim should do a when a file was opened (selected) in yazi.
    -- Defaults to simply opening the file.
    -- open_file_function = function(chosen_file, config) end,

    -- completely override the keymappings for yazi. This function will be
    -- called in the context of the yazi terminal buffer.
    set_keymappings_function = function(yazi_buffer_id, config) end,

    -- the type of border to use for the floating window. Can be many values,
    -- including 'none', 'rounded', 'single', 'double', 'shadow', etc. For
    -- more information, see :h nvim_open_win
    yazi_floating_window_border = 'rounded',

    hooks = {
      -- if you want to execute a custom action when yazi has been opened,
      -- you can define it here.
      -- yazi_opened = function(preselected_path, yazi_buffer_id, config)
      --   -- you can optionally modify the config for this specific yazi
      --   -- invocation if you want to customize the behaviour
      -- end,

      -- when yazi was successfully closed
      -- yazi_closed_successfully = function(chosen_file, config) end,

      -- when yazi opened multiple files. The default is to send them to the
      -- quickfix list, but if you want to change that, you can define it here
      -- yazi_opened_multiple_files = function(chosen_files, config) end,
    },
  },
})

plug({
  enabled = true,
  'stevearc/oil.nvim',
  lazy = (not vim.cfg.runtime__starts_in_buffer and not vim.env.NVIM),
  event = { 'TabEnter', 'TermOpen' },
  cmd = 'Oil',
  opts = {
    --- fix issue when opening nvim inside terminal
    default_file_explorer = not vim.env.NVIM,
    columns = {
      -- 'icon',
    },
    keymaps = {
      ['g?'] = 'actions.show_help',
      ['<CR>'] = 'actions.select',
      ['<C-v>'] = 'actions.select_vsplit',
      ['<C-s>'] = {
        callback = function()
          require('oil').select({ horizontal = true })
        end,
        desc = 'Open the entry under the cursor in a horizontal split',
        nowait = true,
      },
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
      '<leader>f|',
      ':vert Oil<cr>',
      desc = 'Open oil vertical',
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
    au.define_autocmd('BufHidden', {
      group = '_oil_change_cwd',
      pattern = 'oil:///*',
      callback = vim.schedule_wrap(function()
        -- restore locked cwd
        if vim.t.CwdLocked and vim.t.Cwd then
          vim.cmd.lcd(vim.t.Cwd)
        elseif vim.api.nvim_buf_get_name(0) == '' then
          vim.cmd.lcd(vim.cfg.runtime__starts_cwd)
        end
      end),
    })
  end,
})

plug({
  'stevearc/aerial.nvim',
  keys = {
    { '<leader>/o', '<cmd>AerialToggle<cr>', desc = 'Symbols outline' },
    {
      '<C-g>l',
      function()
        local api = require('aerial')
        local util = require('aerial.util')
        local current_is_aerial = vim.bo.filetype == 'aerial'
        if current_is_aerial then
          local source_bufnr = util.get_source_buffer(vim.api.nvim_get_current_buf())
          require('userlib.runtime.buffer').focus_buf_in_visible_windows(source_bufnr)
          return
        elseif vim.bo.buftype == '' then
          api.open({ focus = true, direction = 'left' })
        end
      end,
      desc = 'Symbols outline',
    },
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
    close_on_select = false,
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
  keys = vim.cfg.plugin_fzf_or_telescope == 'telescope'
      and {
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
          '<localleader>.',
          cmd_modcall(pickers_mod, 'buffers_or_recent(true)'),
          desc = 'List Buffers in cwd',
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
            [[project_files(require('userlib.telescope.themes').get_dropdown({ previewer = false, cwd_only = false, oldfiles = true, cwd = vim.cfg.runtime__starts_cwd }))]]
          ),
          desc = 'Open recent files',
        },
        {
          '<leader>fo',
          function()
            --- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/e03ff55962417b69c85ef41424079bb0580546ba/lua/telescope/_extensions/file_browser/actions.lua#L598
            require('telescope').extensions.file_browser.file_browser(require('userlib.telescope.themes').get_dropdown({
              files = false,
              use_fd = true,
              disable_devicons = true,
              display_stat = false,
              hide_parent_dir = true,
              respect_gitignore = true,
              hidden = true,
              previewer = false,
              depth = 3,
              path_display = { 'smart' },
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
            require('telescope').extensions.file_browser.file_browser(require('userlib.telescope.themes').get_dropdown({
              results_title = vim.t.cwd_short,
              files = false,
              disable_devicons = true,
              use_fd = true,
              previewer = false,
              respect_gitignore = true,
              hidden = true,
              depth = 5,
              git_status = false,
              collapse_dirs = false,
              hide_parent_dir = true,
              display_stat = false,
              path_display = { 'smart' },
              cwd = require('userlib.runtime.utils').get_root(),
            }))
          end,
          desc = 'Find project folders',
        },
        {
          '<leader>fg',
          function()
            local isNormal = vim.fn.mode() == 'n'
            local text = isNormal and '' or Ty.buf_vtext()

            local run = function(search)
              require('telescope.builtin').live_grep({
                cwd = vim.cfg.runtime__starts_cwd,
                prompt_title = 'Live Grep (root)',
                search = text == '' and search or text,
                default_text = text == '' and search or text,
              })
            end

            if not isNormal then
              run()
            else
              local search = vim.fn.input({
                prompt = 'Search: ',
              })
              if search == '' then
                return
              end
              run(search)
            end
          end,
          desc = 'Grep search in all projects',
          mode = { 'v', 'x', 'n' },
        },
        {
          '<leader>fs',
          function()
            local text = vim.fn.mode() == 'n' and '' or Ty.buf_vtext()
            require('telescope.builtin').live_grep({
              prompt_title = 'Live Grep in ' .. vim.fn.fnamemodify(vim.uv.cwd() or '', ':t'),
              search = text,
              default_text = text,
            })
          end,
          mode = { 'v', 'x', 'n' },
          desc = 'Grep search in project',
        },
        {
          '<leader>fS',
          function()
            local ext = vim.fn.expand('%:e')
            local text = vim.fn.mode() == 'n' and '' or Ty.buf_vtext()
            require('telescope.builtin').live_grep({
              prompt_title = ('Live Grep%s in ' .. vim.fn.fnamemodify(vim.uv.cwd() or '', ':t')):format(
                ext and '(' .. ext .. ')' or ''
              ),
              glob_pattern = ext and '*.' .. ext or nil,
              search = text,
              default_text = text,
            })
          end,
          mode = { 'v', 'x', 'n' },
          desc = 'Grep search in project in same filetype',
        },
        {
          '<leader>fw',
          function()
            require('telescope.builtin').grep_string({
              search = vim.fn.expand('<cword>'),
              prompt_title = 'Grep String in ' .. vim.fn.fnamemodify(vim.uv.cwd() or '', ':t'),
              default_text = vim.fn.expand('<cword>'),
            })
          end,
          desc = 'Grep search on selection in project',
        },
        {
          '<leader>g.',
          '<cmd>Telescope git_bcommits<cr>',
          desc = 'Show commits for current buffer with diff preview',
        },
        {
          '<leader>fj',
          '<cmd>Telescope jumplist trim_text=true<cr>',
          desc = 'Show jumplist',
        },
      }
    or {},
  dependencies = {
    { 'nvim-lua/popup.nvim' },
    { 'nvim-lua/plenary.nvim' },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      enabled = vim.cfg.plugin_telescope_sorter == 'fzf' or not vim.cfg.plugin_telescope_sorter,
      build = 'make',
    },
    {
      'pze/telescope-nucleo-sorter.nvim',
      enabled = vim.cfg.plugin_telescope_sorter == 'nucleo',
      build = 'cargo rustc --release -- -C link-arg=-undefined -C link-arg=dynamic_lookup',
    },
    {
      'pze/telescope-file-browser.nvim',
      -- branch = 'feat/max-results',
      dev = false,
    },
  },
  config = function(_, opts)
    require('userlib.telescope.spec').config(_, opts)
  end,
  opts = function()
    return require('userlib.telescope.spec').opts()
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
        local cwd = vim.uv.cwd()
        visits.add_label('harpoon', nil, vim.cfg.runtime__starts_cwd)
        if not require('userlib.runtime.path').is_path_equal(cwd, vim.cfg.runtime__starts_cwd) then
          visits.add_label('harpoon', nil, cwd)
        end
        visits.write_index()
        vim.notify('Added to harpoon', vim.log.levels.INFO)
      end,
      silent = false,
      desc = 'Add to visits',
    },
    {
      'mM',
      function()
        vim.b[0].is_harpoon = false
        local visits = require('mini.visits')
        local cwd = vim.uv.cwd()
        visits.remove_label('harpoon', nil, vim.cfg.runtime__starts_cwd)

        if not require('userlib.runtime.path').is_path_equal(cwd, vim.cfg.runtime__starts_cwd) then
          visits.remove_label('harpoon', nil, cwd)
        end

        visits.write_index()
        vim.notify('Removed from harpoon', vim.log.levels.INFO)
      end,
      silent = false,
      desc = 'Remove from visits',
    },
    {
      '<localleader>h',
      function()
        require('userlib.mini.visits').select_by_cwd(vim.uv.cwd(), {
          filter = 'harpoon',
        })
      end,
      desc = 'List harpoon visits (CWD)',
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
      '<leader>pl',
      function()
        require('userlib.mini.visits').list_projects_in_cwd(vim.cfg.runtime__starts_cwd, 'visit_projects')
      end,
      desc = 'List visited projects',
    },
    {
      '<leader>pa',
      function()
        require('userlib.mini.visits').add_project(vim.uv.cwd(), vim.cfg.runtime__starts_cwd)
        vim.notify('Added to project list', vim.log.levels.INFO)
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
      silent = true,
      track = {
        event = 'BufEnter',
        delay = 1000,
      },
    }
  end,
  config = function(_, opts)
    require('mini.visits').setup(opts)
  end,
  init = function()
    require('userlib.legendary').register('harpoon_remove', function(lg)
      lg.funcs({
        {
          function()
            local visits = require('mini.visits')
            local cwd = vim.uv.cwd()
            -- remove all
            visits.remove_label('harpoon', '', cwd)
            visits.write_index()
            vim.notify('Removed harpoon[s]', vim.log.levels.INFO)
          end,
          description = 'Remove harpoons in current project',
        },
      })
    end)
  end,
})

plug({
  -- url = 'https://gitlab.com/ibhagwan/fzf-lua',
  'ibhagwan/fzf-lua',
  -- commit = '36df11e3bbb6453014ff4736f6805b5a91dda56d',
  -- 'pze/fzf-lua',
  dev = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  cond = vim.cfg.plugin_fzf_or_telescope == 'fzf',
  cmd = 'FzfLua',
  event = 'User LazyUIEnterOncePost',
  keys = {
    {
      '<localleader>k',
      function()
        local default_text = vim.fn.mode() ~= 'n' and Ty.buf_vtext() or nil
        if not default_text and vim.v.count >= 1 then
          default_text = vim.g.pre_k_text
        end
        vim.ui.input({
          prompt = 'Query >:',
          default = default_text,
          completion = 'tag',
        }, function(input)
          if input == nil then
            return
          end
          vim.g.pre_k_text = vim.trim(input)
          require('userlib.mini.clue.prequery-action').open(vim.g.pre_k_text)
        end)
      end,
      mode = { 'n', 'v' },
      desc = 'Pre query on text',
    },
    {
      '<localleader>:',
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
      '<localleader>.',
      cmd_modcall(fzf_mod, 'buffers_or_recent(true)'),
      nowait = true,
      desc = 'List local Buffers',
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
      function()
        local isNormal = vim.fn.mode() == 'n'
        local text = isNormal and '' or Ty.buf_vtext()

        require('userlib.fzflua').grep({
          cwd = vim.cfg.runtime__starts_cwd,
          query = text,
        })
      end,
      desc = 'Grep search on selection in all projects',
      mode = { 'v', 'x', 'n' },
    },
    {
      '<leader>fs',
      function()
        local isNormal = vim.fn.mode() == 'n'
        local text = isNormal and '' or Ty.buf_vtext()

        require('userlib.fzflua').grep({
          cwd = vim.t.Cwd or vim.uv.cwd(),
          query = text,
        })
      end,
      desc = 'Grep search on selection in project',
      mode = { 'v', 'x', 'n' },
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
    {
      '<leader>fz',
      cmd_modcall(fzf_mod, [[zoxide_folders()]]),
      desc = 'Zoxide folders',
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
        fullscreen = false,
        width = 0.8,
        height = 0.75,
        preview = {
          delay = 150,
          scrollbar = false,
          default = 'builtin',
          wrap = 'wrap',
          layout = 'flex',
          flip_columns = 240,
          horizontal = 'right:45%',
          vertical = 'down:40%',
          winopts = {
            cursorlineopt = 'line',
            foldcolumn = 0,
          },
        },
      },
      keymap = {
        fzf = {
          ['ctrl-z'] = 'abort',
          ['ctrl-f'] = 'half-page-down',
          ['ctrl-b'] = 'half-page-up',
          ['ctrl-a'] = 'beginning-of-line',
          ['ctrl-e'] = 'end-of-line',
          ['alt-a'] = 'toggle-all',
          ['ctrl-q'] = 'select-all+accept',
        },
      },
      files = {
        formatter = 'path.filename_first',
      },
      grep = {
        formatter = 'path.filename_first',
        winopts = {
          -- split = 'belowright new',
        },
      },
      oldfiles = {
        formatter = 'path.filename_first',
      },
      buffers = {
        formatter = 'path.filename_first',
      },
      live_grep = {
        formatter = 'path.filename_first',
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
        ['--info'] = 'inline',
        ['--height'] = '100%',
        ['--layout'] = 'reverse',
        ['--margin'] = '0%',
        ['--padding'] = '0%',
        ['--border'] = 'none',
        ['--cycle'] = '',
        ['--no-separator'] = '',
      },
      previewers = {
        builtin = {
          syntax_limit_l = 8000,
          syntax_limit_b = 1024 * 50,
          limit_b = 1024 * 50,
        },
      },
      fzf_colors = {
        -- ['bg'] = { 'bg', { 'NormalFloat' } },
        -- ['border'] = { 'fg', { 'FloatBorder' } },
        -- ['gutter'] = { 'bg', { 'NormalFloat' } },
        -- ['bg+'] = { 'bg', { 'CursorLine' } },
      },
    })

    -- registered with dressing.
    -- local enable_fzf_select = vim.cfg.ui__input_select_provider == 'fzf-lua'
    local enable_fzf_select = false

    if not enable_fzf_select then
      return
    end

    fzflua.register_ui_select({
      winopts = {
        fullscreen = false,
        height = 0.30,
        width = 0.70,
      },
      fzf_opts = {
        ['--no-hscroll'] = '',
        ['--delimiter'] = '[\\.\\s]',
        ['--with-nth'] = '3..',
      },
    })
  end,
})
