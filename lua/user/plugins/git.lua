local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')
local cmdstr = require('userlib.runtime.keymap').cmdstr

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
  {
    'kdheepak/lazygit.nvim',
    cmd = 'LazyGit',
    keys = {
      {
        '<leader>gl',
        '<cmd>LazyGit<cr>',
        desc = 'Open Lazygit',
      },
    },
  },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gg', ':Git<cr>',            desc = 'Fugitive Git' },
      { '<leader>gG', ':tab Git<cr>',        desc = 'Fugitive Git in tab' },
      { '<leader>ga', cmdstr([[Git add %]]), desc = '!Git add current' },
      { '<leader>gA', cmdstr([[Git add .]]), desc = '!Git add all' },
      { '<leader>gP', cmdstr([[Git push]]),  desc = 'Git push' },
      { '<leader>gp', cmdstr([[Git pull]]),  desc = 'Git pull' },
    },
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
            if ft ~= 'fugitive' then return end
            vim.cmd('normal! gg5j')
          end)
        end,
      })
    end,
  },
  {
    -- git runtimes. ft etc.
    'tpope/vim-git',
    event = { 'BufReadPre' },
    enabled = true,
    cond = function() return true end,
  },

  {
    'sindrets/diffview.nvim',
    keys = {
      {
        '<leader>gf',
        '<cmd>lua require("userlib.git.utils").toggle_files_history()<cr>',
        desc = 'Files history',
      },
      {
        '<leader>gF',
        [[<cmd>lua require("userlib.git.utils").toggle_files_history(nil, '%')<cr>]],
        desc = 'Current file history(diffview)',
      },
      ---FIXME: <Space>e keymap not reset when exist the diffview. it should be buffer local keymaps.
      {
        '<leader>gs',
        '<cmd>lua require("userlib.git.utils").toggle_working_changes()<cr>',
        desc = 'Current status/changes',
      },
      {
        '<leader>gq',
        '<cmd>lua require("userlib.git.utils").close_git_views()<cr>',
        desc = 'Quite git views',
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
    config = function(_, opts) require('diffview').setup(opts) end,
    init = function()
      au.define_autocmd('BufEnter', {
        pattern = 'diffview://*',
        group = 'diffview_bindings',
        callback = function(args)
          local buf = args.buf
          local set = require('userlib.runtime.keymap').map_buf_thunk(buf)
          set('n', '<S-q>', function() require('userlib.git.utils').close_git_views() end, {
            desc = 'quit diffview',
          })
        end,
      })
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    keys = {
      {
        'gh',
        '<cmd>lua require("userlib.hydra.git").open_git_signs_hydra()<cr>',
      },
    },
    event = au.user_autocmds.FileOpenedAfter_User,
    config = function()
      local gitsigns_current_blame_delay = 0
      local autocmd = require('userlib.runtime.au')

      local signs = require('gitsigns')
      require('userlib.legendary').pre_hook(
        'git_lg',
        function(lg) lg.commands(require('userlib.legendary.commands.git')) end
      )

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
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = gitsigns_current_blame_delay,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
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
        if info.vcs == 'git' and vim.fn.getline(1) == '' then vim.schedule(function() vim.cmd.startinsert() end) end
      end,
    }
  end,
})

plug({
  -- 'pze/git-conflict.nvim',
  'akinsho/git-conflict.nvim',
  dev = false,
  event = au.user_autocmds.FileOpenedAfter_User,
  version = 'v1.2.2',
  keys = {
    {
      '<leader>gc',
      '<cmd>lua require("userlib.hydra.git").open_git_conflict_hydra()<cr>',
      desc = 'Open git conflict menus',
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
      default_mappings = true,    -- disable buffer local mapping created by this plugin
      default_commands = true,
      disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
      highlights = {              -- They must have background color, otherwise the default color will be used
        incoming = 'DiffAdd',
        current = 'DiffAdd',
      },
    })

    vim.schedule(function() vim.cmd('GitConflictRefresh') end)
  end,
})

plug({
  'Arrow-x/git-worktree.nvim',
  keys = {
    {
      '<leader>gw',
      '<cmd>lua require("telescope").extensions.git_worktree.git_worktrees()<cr>',
      desc = 'Git worktree',
    }
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
