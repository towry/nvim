local plug = require('libs.runtime.pack').plug
local au = require('libs.runtime.au')
local cmdstr = require('libs.runtime.keymap').cmdstr


plug({
  {
    'kdheepak/lazygit.nvim',
    cmd = 'LazyGit',
    keys = {
      {
        '<leader>gl', '<cmd>LazyGit<cr>', desc = 'Open Lazygit',
      }
    }
  },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gg', ":Git<cr>",               desc = "Fugitive Git" },
      { '<leader>ga', cmdstr([[!git add %:p]]), desc = "Git add current" },
      { '<leader>gA', cmdstr([[!git add .]]),   desc = "Git add all" },
      { '<leader>gm', cmdstr([[G commit]]),     desc = "Git commit" },
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
      'Gblame',
      'Gvdiff',
      'Gsdiff',
      'Gdiff',
      'Gpedit',
    },
  },
  {
    --
    'shumphrey/fugitive-gitlab.vim',
    dependencies = {
      'tpope/vim-fugitive',
    },
  },
  {
    -- git runtimes. ft etc.
    'tpope/vim-git',
    event = au.user_autocmds.FileOpenedAfter_User,
    cond = function() return true end,
  },
  {
    -- tig like git commit browser.
    'junegunn/gv.vim',
    cmd = { 'GV' },
    dependencies = {
      'tpope/vim-fugitive',
    },
  },

  {
    'sindrets/diffview.nvim',
    keys = {
      { '<leader>gD', '<cmd>lua require("libs.git.utils").toggle_file_history()<cr>',    desc = 'Git file history' },
      { '<leader>gd', '<cmd>lua require("libs.git.utils").toggle_working_changes()<cr>', desc = 'Git changes' },
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
          layout = "diff2_vertical",
          winbar_info = false,
        },
      },
      keymaps = {
        disable_defaults = false,
      },
      hooks = {
        diff_buf_read = function(bufnr)
          local autocmd = require('libs.runtime.au')
          autocmd.fire_event(autocmd.events.onGitDiffviewBufRead, {
            bufnr = bufnr,
          })
        end,
        view_opened = function(view)
          local autocmd = require('libs.runtime.au')
          autocmd.fire_event(autocmd.events.onGitDiffviewOpen, {
            view = view,
          })
        end
      }
    },
    config = function(_, opts)
      require('diffview').setup(opts)
    end,
  },

  {
    'akinsho/git-conflict.nvim',
    event = au.user_autocmds.FileOpenedAfter_User,
    version = '*',
    keys = {
      {
        '<leader>gc',
        '<cmd>lua require("libs.hydra.git").open_git_conflict_hydra()<cr>',
        desc = 'Open git conflict menus',
      }
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
        default_mappings = false,   -- disable buffer local mapping created by this plugin
        default_commands = true,
        disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
        highlights = {              -- They must have background color, otherwise the default color will be used
          -- incoming = 'DiffText',
          -- current = 'DiffAdd',
        },
      })
    end,
  },

  {
    'ThePrimeagen/git-worktree.nvim',
    config = function()
      local present, worktree = pcall(require, 'git-worktree')
      if not present then return end

      local utils = require('libs.runtime.utils')
      local au = require('libs.runtime.au')

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Setup                                                    │
      -- ╰──────────────────────────────────────────────────────────╯
      worktree.setup({
        change_directory_command = 'cd',  -- default: "cd",
        update_on_change = true,          -- default: true,
        update_on_change_command = 'e .', -- default: "e .",
        clearjumps_on_change = true,      -- default: true,
        autopush = false,                 -- default: false,
      })

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Keymappings                                              │
      -- ╰──────────────────────────────────────────────────────────╯
      -- <Enter> - switches to that worktree
      -- <c-d> - deletes that worktree
      -- <c-f> - toggles forcing of the next deletion
      -- keymap("n", "<Leader>gww", "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>", silent)

      -- First a telescope git branch window will appear.
      -- Presing enter will choose the selected branch for the branch name.
      -- If no branch is selected, then the prompt will be used as the branch name.

      -- After the git branch window,
      -- a prompt will be presented to enter the path name to write the worktree to.

      -- As of now you can not specify the upstream in the telescope create workflow,
      -- however if it finds a branch of the same name in the origin it will use it
      -- keymap("n", "<Leader>gwc", "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>", silent)

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Hooks                                                    │
      -- ╰──────────────────────────────────────────────────────────╯
      -- op = Operations.Switch, Operations.Create, Operations.Delete
      -- metadata = table of useful values (structure dependent on op)
      --      Switch
      --          path = path you switched to
      --          prev_path = previous worktree path
      --      Create
      --          path = path where worktree created
      --          branch = branch name
      --          upstream = upstream remote name
      --      Delete
      --          path = path where worktree deleted

      worktree.on_tree_change(function(op, metadata)
        if op == worktree.Operations.Switch then
          utils.log('Switched from ' .. metadata.prev_path .. ' to ' .. metadata.path, 'Git Worktree')
          au.fire_event(au.events.doBufferCloseAllButCurrent)
          vim.cmd('e')
        end
      end)
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    keys = {
      {
        'gh', '<cmd>lua require("libs.hydra.git").open_git_signs_hydra()<cr>'
      }
    },
    event = au.user_autocmds.FileOpenedAfter_User,
    config = function()
      local gitsigns_current_blame_delay = 0

      local signs = require('gitsigns')
      local autocmd = require('libs.runtime.au')

      -- register legendary
      autocmd.define_user_autocmd({
        pattern = au.user_autocmds.LegendaryConfigDone,
        callback = function()
          require('legendary').commands(require('libs.legendary.commands.git'))
        end,
      })

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Setup                                                    │
      -- ╰──────────────────────────────────────────────────────────╯
      signs.setup({
        signs = {
          add = { hl = 'GitSignsAdd', text = '┃', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
          change = { hl = 'GitSignsChange', text = '┃', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
          delete = { hl = 'GitSignsDelete', text = '┃', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
          topdelete = { hl = 'GitSignsDelete', text = '┃', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
          changedelete = { hl = 'GitSignsChangeNr', text = '┃', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
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
