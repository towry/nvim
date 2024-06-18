local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')
local cmdstr = require('userlib.runtime.keymap').cmdstr
local libutils = require('userlib.runtime.utils')

plug({
  'mbbill/undotree',
  keys = {
    {
      '<leader>bu',
      '<cmd>:UndotreeToggle<cr>',
      desc = 'Toggle undo tree',
    },
  },
  cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow' },
  init = function()
    local g = vim.g
    g.undotree_WindowLayout = 1
    g.undotree_SetFocusWhenToggle = 1
    g.undotree_SplitWidth = 30
    g.undotree_DiffAutoOpen = 1
  end,
})

plug({
  'junegunn/gv.vim',
  dependencies = {
    'tpope/vim-fugitive',
  },
  cmd = 'GV',
  config = false,
  keys = {
    {
      '<leader>gz',
      '<cmd>GV<cr>',
      desc = 'Git logs with GV',
    },
  },
})

plug({
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-dispatch',
    },
    keys = {
      {
        '<leader>g1',
        function()
          local res = vim
            .system({
              'git',
              'log',
              '--oneline',
              '--date=relative',
              '--abbrev',
              '--no-color',
              '--pretty=format:%s (%an)',
              '-3',
            }, { text = true })
            :wait()
          if res.code == 0 then
            vim.notify('   \n' .. res.stdout, vim.log.levels.INFO)
          else
            vim.notify(res.stderr, vim.log.levels.ERROR)
          end
        end,
        desc = 'Emit HEAD commit info',
      },
      { '<leader>g.', ':Git', desc = 'Fugitive start :Git' },
      { '<leader>gm', ':Git merge', desc = 'Fugitive start git merge' },
      {
        '<leader>gg',
        ':Git | resize +10<cr>',
        desc = 'Fugitive Git',
      },
      {
        '<leader>gG',
        ':tab Git<cr>',
        desc = 'Fugitive Git in tab',
      },
      {
        '<leader>ga',
        cmdstr([[OverDispatch! git add -- % && git diff --cached --check || echo Conflict founds || exit 1]]),
        desc = '!Git add current',
      },
      {
        '<leader>gtd',
        cmdstr([[tab Gdiffsplit]]),
        desc = 'Git diff in tab',
      },
      {
        '<leader>gA',
        cmdstr([[OverDispatch! git add .]]),
        desc = '!Git add all',
      },
      {
        '<leader>gp',
        cmdstr([[exec "OverDispatch! git push --force-with-lease origin " .. FugitiveHead()]]),
        desc = 'Git push',
      },
      {
        '<leader>gu',
        function()
          vim.g.escape_cmd = 'pclose'
          vim.cmd('OverDispatch git pull --ff origin ' .. vim.fn.FugitiveHead())
        end,
        desc = 'Git pull',
        silent = false,
      },
      {
        '<leader>gs',
        function()
          vim.cmd([[tab Git diff HEAD]])
          -- vim.cmd([[:lua vim.bo.syntax="diff"]])
        end,
        desc = 'Git status with Fugitive on HEAD',
        silent = false,
      },
      {
        '<leader>gl',
        function()
          -- https://github.com/niuiic/git-log.nvim/blob/main/lua/git-log/init.lua
          local file_name = vim.api.nvim_buf_get_name(0)
          local line_range = libutils.get_range()
          local cmd =
            string.format([[vert Git log --max-count=100 -L %s,%s:%s]], line_range[1], line_range[2], file_name)
          vim.print(cmd)
          vim.cmd(cmd)
        end,
        desc = 'View log for selected chunks',
        mode = { 'v', 'x' },
      },
      {
        '<leader>gl',
        function()
          local vcount = vim.v.count
          local max_count_arg = ''
          if vcount ~= 0 and vcount ~= nil and vcount > 0 then
            max_count_arg = string.format('--max-count=%s', vcount)
          end
          vim.cmd(
            'vert Git log -P '
              .. max_count_arg
              .. ' --oneline --date=format:"%Y-%m-%d %H:%M" --pretty=format:"%h %ad: %s - %an" -- %'
          )
        end,
        desc = 'Git show current file history',
      },
      {
        -- git log with -p for current buffer. with limits for performance.
        '<leader>gL',
        function()
          local vcount = vim.v.count
          local max_count_arg = ''
          if vcount ~= 0 and vcount ~= nil and vcount > 0 then
            max_count_arg = string.format('--max-count=%s', vcount)
          end
          vim.cmd(string.format([[Git log %s -p -m --first-parent -P -- %s]], max_count_arg, vim.fn.expand('%')))
        end,
        desc = 'Git show current file history with diff',
      },
      {
        '<leader>gd',
        cmdstr([[Git diff -- %]]),
        desc = 'Diff current file',
      },
      {
        '<leader>gD',
        cmdstr([[Git diff -- %]]),
        desc = 'Diff current file unified',
      },
      {
        '<leader>gb',
        cmdstr([[Git blame -n --date=short --color-lines --show-stats %]]),
        desc = 'Git blame current file',
      },
      {
        '<leader>gb',
        function()
          local file_name = vim.api.nvim_buf_get_name(0)
          local line_range = libutils.get_range()
          vim.cmd(
            string.format(
              [[Git blame -n --date=short --color-lines -L %s,%s %s]],
              line_range[1],
              line_range[2],
              file_name
            )
          )
        end,
        mode = 'x',
        desc = 'Git blame current file with range',
      },
      {
        '<leader>gx',
        '<cmd>silent OverDispatch! git add -- % && git diff --cached --check --quiet || git commit --amend --no-edit<cr>',
        desc = 'Git amend all',
      },
      {
        '<leader>gc',
        function()
          -- use vim.ui.input to write commit message and then commit with the
          -- message.
          vim.ui.input({
            prompt = 'Commit message: ',
          }, function(input)
            -- if input is trimmed empty
            if vim.trim(input or '') == '' then
              vim.notify('Empty commit message', vim.log.levels.ERROR)
              return
            end
            vim.cmd(string.format('OverDispatch! git commit -m "%s"', input))
          end)
        end,
        desc = 'Git commit',
      },
    },
    event = 'VeryLazy',
    cmd = {
      'G',
      'Git',
      'Gread',
      'Gwrite',
      'Ggrep',
      'GMove',
      'GDelete',
      'GBrowse',
      'Gdiffsplit',
      'Gvdiffsplit',
      'Gedit',
      'Gsplit',
      'Grevert',
      'Grebase',
      'Gpedit',
      'Gclog',
    },
    init = function()
      vim.api.nvim_create_autocmd('BufWinEnter', {
        pattern = '*fugitive://*',
        group = vim.api.nvim_create_augroup('_plug_fug_auto_jump_', { clear = true }),
        callback = function()
          vim.schedule(function()
            local ft = vim.bo.filetype
            if ft ~= 'fugitive' then
              return
            end
            vim.cmd('normal! gg5j')
          end)
        end,
      })
    end,
  },
  {
    -- git runtimes. ft etc.
    'tpope/vim-git',
    event = 'User LazyUIEnter',
  },

  {
    'sindrets/diffview.nvim',
    keys = {
      {
        '<leader>gf',
        '<cmd>lua require("userlib.git.utils").toggle_files_history()<cr>',
        desc = '[DV] Files history, commits view',
      },
      {
        '<leader>gF',
        [[<cmd>lua require("userlib.git.utils").toggle_files_history(nil, '%')<cr>]],
        desc = '[DV] Current file history(diffview)',
      },
      ---FIXME: <Space>e keymap not reset when exist the diffview. it should be buffer local keymaps.
      {
        '<leader>gS',
        '<cmd>lua require("userlib.git.utils").toggle_working_changes()<cr>',
        desc = '[DV] Current status/changes',
      },
      {
        '<leader>gq',
        '<cmd>lua require("userlib.git.utils").close_git_views()<cr>',
        desc = '[DV] Quite git views',
      },
    },
    cmd = {
      'DiffviewLog',
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewRefresh',
      'DiffviewFocusFile',
      'DiffviewFileHistory',
      'DiffviewToggleFiles',
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = 'diff2_vertical',
          winbar_info = false,
        },
      },
      keymaps = {
        disable_defaults = false,
      },
      hooks = {
        diff_buf_read = function(bufnr)
          local autocmd = require('userlib.runtime.au')
          autocmd.fire_event(autocmd.events.onGitDiffviewBufRead, {
            bufnr = bufnr,
          })
        end,
        view_opened = function(view)
          local autocmd = require('userlib.runtime.au')
          autocmd.fire_event(autocmd.events.onGitDiffviewOpen, {
            view = view,
          })
        end,
      },
    },
    config = function(_, opts)
      require('diffview').setup(opts)
    end,
    init = function()
      au.define_autocmd('BufEnter', {
        pattern = 'diffview://*',
        group = 'diffview_bindings',
        callback = function(args)
          local buf = args.buf
          local set = require('userlib.runtime.keymap').map_buf_thunk(buf)
          set('n', '<C-q>', function()
            require('userlib.git.utils').close_git_views()
          end, {
            desc = 'quit diffview',
          })
        end,
      })
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    cond = not vim.g.is_start_as_merge_tool,
    keys = {
      {
        'ghd',
        '<cmd>Gitsigns diffthis<cr>',
        desc = 'Diff this',
      },
      {
        'ghs',
        '<cmd>Gitsigns stage_hunk<cr>',
        desc = 'Stage hunk',
      },
      {
        'ghr',
        '<cmd>Gitsigns reset_hunk<cr>',
        mode = { 'n', 'v' },
        desc = 'Reset hunk',
      },
      {
        'gha',
        '<cmd>Gitsigns stage_buffer<cr>',
        desc = 'Stage buffer',
      },
      {
        'ghu',
        '<cmd>Gitsigns undo_stage_hunk<cr>',
        mode = { 'n', 'v' },
        desc = 'Undo stage hunk',
      },
      {
        'ghR',
        '<cmd>Gitsigns reset_buffer<cr>',
        desc = 'Reset buffer',
      },
      {
        'ghp',
        '<cmd>Gitsigns preview_hunk<cr>',
        desc = 'Preview hunk',
      },
      {
        'ghP',
        '<cmd>Gitsigns preview_hunk_inline<cr>',
        desc = 'Preview hunk inline',
      },
      {
        'ghB',
        '<cmd>Gitsigns blame_line<cr>',
        desc = 'Blame line',
      },
      {
        'ghb',
        '<cmd>Gitsigns toggle_current_line_blame<cr>',
        desc = 'Toggle current line blame',
      },
      {
        'ghv',
        '<cmd>Gitsigns toggle_signs<cr>',
        desc = 'Toggle signs',
      },
      {
        'ghx',
        '<cmd>Gitsigns select_hunk<cr>',
        desc = 'Select hunk',
      },
      {
        'gh]',
        function()
          local gs = require('gitsigns')
          if vim.wo.diff then
            return
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
        end,
        desc = 'Next hunk',
      },
      {
        'gh[',
        function()
          local gs = require('gitsigns')
          if vim.wo.diff then
            return
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
        end,
        desc = 'Prev hunk',
      },
    },
    event = 'VeryLazy',
    config = function()
      local gitsigns_current_blame_delay = 0
      local autocmd = require('userlib.runtime.au')

      local signs = require('gitsigns')
      require('userlib.legendary').pre_hook('git_lg', function(lg)
        lg.commands(require('userlib.legendary.commands.git'))
      end)

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Setup                                                    │
      -- ╰──────────────────────────────────────────────────────────╯
      signs.setup({
        signs = {
          add = { hl = 'GitSignsAdd', text = '┃', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
          change = { hl = 'GitSignsChange', text = '┃', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
          delete = { hl = 'GitSignsDelete', text = '┃', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
          topdelete = { hl = 'GitSignsDelete', text = '┃', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
          changedelete = {
            hl = 'GitSignsChangeNr',
            text = '┃',
            numhl = 'GitSignsChangeNr',
            linehl = 'GitSignsChangeLn',
          },
          untracked = { hl = 'GitSignsAddNr', text = '┃', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        },
        signcolumn = not vim.cfg.runtime__starts_as_gittool, -- Toggle with `:Gitsigns toggle_signs`
        numhl = vim.cfg.runtime__starts_as_gittool, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with`:Gitsigns toggle_word_diff`
        watch_gitdir = {
          interval = vim.cfg.runtime__starts_as_gittool and 3000 or 1000,
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = vim.cfg.runtime__starts_as_gittool, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = gitsigns_current_blame_delay,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        sign_priority = 6,
        update_debounce = vim.cfg.runtime__starts_as_gittool and 1000 or 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000,
        preview_config = {
          -- Options passed to nvim_open_win
          border = vim.cfg.ui__float_border,
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1,
        },
        yadm = {
          enable = false,
        },
        on_attach = function(bufnr)
          autocmd.fire_event(autocmd.events.onGitsignsAttach, {
            bufnr = bufnr,
          })
        end,
      })
    end,
  },
})

---better commit view.
plug({
  'rhysd/committia.vim',
  ft = { 'gitcommit' },
  enabled = false,
  init = function()
    vim.g.committia_min_window_width = 30
    vim.g.committia_edit_window_width = 75
    vim.g.committia_open_only_vim_starting = 1

    vim.api.nvim_create_user_command('CommittiaOpenGit', function()
      require('userlib.runtime.utils').load_plugins({ 'committia.vim' })
      vim.fn['committia#open']('git')
    end, {})

    -- vim.api.nvim_create_autocmd('BufReadPre', {
    --   pattern = { 'MERGE_MSG' },
    --   group = vim.api.nvim_create_augroup('_gitcommit', { clear = true }),
    --   callback = function()
    --     require('userlib.runtime.utils').load_plugins({ 'committia.vim' })
    --     vim.fn['committia#open']('git')
    --   end
    -- })

    vim.g.committia_hooks = {
      edit_open = function(info)
        vim.cmd.resize(10)
        local opts = {
          buffer = vim.api.nvim_get_current_buf(),
          silent = true,
        }
        local function imap(lhs, rhs, normal)
          local modes = normal and { 'i', 'n' } or { 'i' }
          vim.keymap.set(modes, lhs, rhs, opts)
        end

        imap('<C-d>', '<Plug>(committia-scroll-diff-down-half)', true)
        imap('<C-u>', '<Plug>(committia-scroll-diff-up-half)', true)
        imap('<C-f>', '<Plug>(committia-scroll-diff-down-page)', true)
        imap('<C-b>', '<Plug>(committia-scroll-diff-up-page)', true)
        imap('<C-j>', '<Plug>(committia-scroll-diff-down)')
        imap('<C-k>', '<Plug>(committia-scroll-diff-up)')

        -- if no commit message, start in insert mode.
        if info.vcs == 'git' and vim.fn.getline(1) == '' then
          vim.schedule(function()
            vim.cmd.startinsert()
          end)
        end
      end,
    }
  end,
})

plug({
  -- TODO: how to start inside nvim automatically
  'whiteinge/diffconflicts',
  cmd = { 'DiffConflicts', 'DiffConflictsWithHistory' },
  event = 'VeryLazy',
  lazy = not vim.cfg.runtime__starts_as_gittool,
  config = function() end,
})
plug({
  -- 'pze/git-conflict.nvim',
  'akinsho/git-conflict.nvim',
  dev = false,
  enabled = false,
  event = au.user_autocmds.FileOpenedAfter_User,
  version = 'v1.3.0',
  keys = {
    {
      '<leader>gcb',
      '<cmd>GitConflictChooseBoth<cr>',
      desc = 'Git conflict choose both',
    },
    {
      '<leader>gcn',
      '<cmd>GitConflictNextConflict<cr>',
      desc = 'Git conflict next conflict',
    },
    {
      '<leader>gco',
      '<cmd>GitConflictChooseOurs<cr>',
      desc = 'Git conflict choose ours',
    },
    {
      '<leader>gcp',
      '<cmd>GitConflictPrevConflict<cr>',
      desc = 'Git conflict prev conflict',
    },
    {
      '<leader>gct',
      '<cmd>GitConflictChooseTheirs<cr>',
      desc = 'Git conflict choose theirs',
    },
    {
      '<leader>gcl',
      '<cmd>GitConflictListQf<cr>',
      desc = 'Git conflict list qf',
    },
    {
      '<leader>gcN',
      '<cmd>GitConflictChooseNone<cr>',
      desc = 'Git conflict choose none',
    },
    {
      '<leader>gcr',
      '<cmd>GitConflictRefresh<cr>',
      desc = 'Git conflict refresh',
    },
  },
  cmd = {
    'GitConflictChooseBoth',
    'GitConflictNextConflict',
    'GitConflictChooseOurs',
    'GitConflictPrevConflict',
    'GitConflictChooseTheirs',
    'GitConflictListQf',
    'GitConflictChooseNone',
    'GitConflictRefresh',
  },
  config = function()
    local conflict = require('git-conflict')

    conflict.setup({
      default_mappings = true, -- disable buffer local mapping created by this plugin
      default_commands = true,
      disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
      -- highlights = {              -- They must have background color, otherwise the default color will be used
      --   incoming = 'DiffAdd',
      --   current = 'DiffAdd',
      -- },
    })

    vim.schedule(function()
      vim.cmd('GitConflictRefresh')
    end)
  end,
})

plug({
  'Arrow-x/git-worktree.nvim',
  keys = {
    {
      '<leader>gw',
      '<cmd>lua require("telescope").extensions.git_worktree.git_worktrees()<cr>',
      desc = 'Git worktree',
    },
  },
  opts = {
    autopush = false,
  },
  init = function()
    au.define_user_autocmd({
      pattern = 'TelTelescopeConfigDone',
      callback = function()
        require('telescope').load_extension('git_worktree')
      end,
    })
  end,
})
