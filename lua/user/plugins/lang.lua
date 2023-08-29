local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')

plug({
  {
    --- some issues
    --- https://github.com/nvim-treesitter/nvim-treesitter/issues/3970#issuecomment-1353836834
    --- https://github.com/nvim-treesitter/nvim-treesitter/issues/2014#issuecomment-970342040
    --- `:echo nvim_get_runtime_file('*/python.so', v:true)`
    'nvim-treesitter/nvim-treesitter',
    build = function()
      if #vim.api.nvim_list_uis() == 0 then
        -- update sync if running headless
        vim.cmd.TSUpdateSync()
      else
        -- otherwise update async
        vim.cmd.TSUpdate()
      end
    end,
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      -- { "<Enter>",    desc = "Init Increment selection" },
      -- { "<Enter>",    desc = "node node incremental selection",      mode = "x" },
      { '<BS>', desc = 'Decrement selection', mode = 'x' },
    },
    dependencies = {
      'windwp/nvim-ts-autotag',
      'andymass/vim-matchup',
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        init = function()
          -- PERF: no need to load the plugin, if we only need its queries for mini.ai
          local plugin = require('lazy.core.config').spec.plugins['nvim-treesitter']
          local opts = require('lazy.core.plugin').values(plugin, 'opts', false)
          local enabled = false
          if opts.textobjects then
            for _, mod in ipairs({ 'move', 'select', 'swap', 'lsp_interop' }) do
              if opts.textobjects[mod] and opts.textobjects[mod].enable then
                enabled = true
                break
              end
            end
          end
          if not enabled then require('lazy.core.loader').disable_rtp_plugin('nvim-treesitter-textobjects') end
        end,
      },
      -- setting the commentstring option based on the cursor location in the file. The location is checked via treesitter queries.
      -- Vue files can have many different sections, each of which can have a different style for comments.
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    init = function()
      -- vim.opt.smartindent = false
      vim.g.matchup_matchparen_offscreen = {
        method = 'popup',
      }
    end,
    config = function()
      local Buffer = require('userlib.runtime.buffer')
      local disabled = function(_lang, bufnr)
        --- must after buffer is read and loaded, otherwise some option is not available.
        local ft = vim.api.nvim_get_option_value('filetype', {
          buf = bufnr,
        })
        if vim.tbl_contains(vim.cfg.lang__treesitter_plugin_disable_on_filetypes or {}, ft) then return true end
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })
        if buftype ~= '' then return true end
        -- great than 100kb or lines great than 20000
        return vim.api.nvim_buf_line_count(bufnr) > 20000 or Buffer.getfsize(bufnr) > 100000
      end
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.configs').setup({
        -- parser_install_dir = parser_install_dir,
        ensure_installed = vim.cfg.lang__treesitter_ensure_installed,
        highlight = {
          disable = disabled,
          enable = vim.cfg.lang__treesitter_plugin_highlight,
          -- disable = { "c", "rust" },  -- list of language that will be disabled
          additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
          enable = vim.cfg.lang__treesitter_plugin_incremental_selection,
          disable = disabled,
          keymaps = {
            init_selection = '<S-Enter>',
            node_incremental = '<Enter>',
            scope_incremental = '<S-Enter>',
            node_decremental = '<BS>',
          },
        },
        indent = {
          enable = true,
        },
        context_commentstring = {
          enable = vim.cfg.lang__treesitter_plugin_context_commentstring,
          -- enable_autocmd = false,
        },
        autotag = {
          enable = true,
        },
        matchup = {
          enable = true,
          include_match_words = true,
        },
        textobjects = {
          move = {
            disable = disabled,
            enable = vim.cfg.lang__treesitter_plugin_textobjects_move,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']]'] = '@function.outer',
              [']m'] = '@class.outer',
            },
            goto_next_end = {
              [']['] = '@function.outer',
              [']M'] = '@class.outer',
            },
            goto_previous_start = {
              ['[['] = '@function.outer',
              ['[m'] = '@class.outer',
            },
            goto_previous_end = {
              ['[]'] = '@function.outer',
              ['[M'] = '@class.outer',
            },
          },
          swap = {
            enable = false,
          },
        }, -- end textobjects
      })
    end,
  },
  {
    'NvChad/nvim-colorizer.lua',
    ft = {
      'html',
      'css',
      'javascript',
      'typescript',
      'typescriptreact',
      'javascriptreact',
      'lua',
      'sass',
      'scss',
      'less',
    },
    opts = {
      filetypes = {
        'html',
        'css',
        'javascript',
        'typescript',
        'typescriptreact',
        'javascriptreact',
        'lua',
        'sass',
        'scss',
        'less',
      },
      user_default_options = {
        mode = 'background',
        tailwind = true, -- Enable tailwind colors
      },
    },
  },

  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    opts = function()
      return {
        ---Add a space b/w comment and the line
        ---@type boolean
        padding = true,
        ---Lines to be ignored while comment/uncomment.
        ---Could be a regex string or a function that returns a regex string.
        ---Example: Use '^$' to ignore empty lines
        ---@type string|function
        ignore = nil,
        ---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
        ---@type table
        mappings = {
          ---operator-pending mapping
          ---Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
          basic = true,
          ---extra mapping
          ---Includes `gco`, `gcO`, `gcA`
          extra = true,
          ---extended mapping
          ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
          extended = false,
        },
        ---LHS of toggle mapping in NORMAL + VISUAL mode
        ---@type table
        toggler = {
          ---line-comment keymap
          line = 'gcc',
          ---block-comment keymap
          block = 'gbc',
        },
        ---LHS of operator-pending mapping in NORMAL + VISUAL mode
        ---@type table
        opleader = {
          ---line-comment keymap
          line = 'gc',
          ---block-comment keymap
          block = 'gb',
        },
        ---Pre-hook, called before commenting the line
        ---@type function|nil
        pre_hook = function(ctx)
          return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
        end,
        ---Post-hook, called after commenting is done
        ---@type function|nil
        post_hook = nil,
      }
    end,
  },

  {
    'danymat/neogen',
    cmd = 'Neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = true,
  },

  {
    'folke/todo-comments.nvim',
    cmd = {
      'TodoTrouble',
    },
    keys = {
      {
        ']td',
        "<cmd>lua require('todo-comments').jump_next()<CR>",
        desc = 'Jump to next todo',
      },
      {
        '[td',
        "<cmd>lua require('todo-comments').jump_prev()<CR>",
        desc = 'Jump to next todo',
      },
    },
    event = au.user_autocmds.FileOpenedAfter_User,
    config = function()
      local todo_comments = require('todo-comments')

      todo_comments.setup({
        signs = false, -- show icons in the signs column
        sign_priority = 8, -- sign priority
        -- keywords recognized as todo comments
        keywords = {
          FIX = {
            alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          },
          WARN = { alt = { 'WARNING' } },
          PERF = { alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        },
        highlight = {
          before = '', -- "fg" or "bg" or empty
          -- keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
          keyword = 'wide', -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
          after = '', -- "fg" or "bg" or empty
          pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
          comments_only = true, -- uses treesitter to match keywords in comments only
          max_line_len = 1500, -- ignore lines longer than this
          exclude = {}, -- list of file types to exclude highlighting
        },
      })
    end,
  },
  {
    'm-demare/hlargs.nvim',
    event = au.user_autocmds.FileOpenedAfter_User,
    opts = {
      color = '#F7768E',
    },
  },

  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && npm install',
    init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
    ft = { 'markdown' },
  },

  {
    'vuki656/package-info.nvim',
    enabled = false,
    event = 'BufEnter package.json',
    init = function()
      au.define_autocmd({
        'BufEnter',
      }, {
        pattern = 'package.json',
        callback = function(ctx)
          local opts = {
            buffer = ctx.buf,
            noremap = true,
            silent = true,
            nowait = true,
          }
          local set = vim.keymap.set
          set('n', '<localleader>pi', '<cmd>lua require("package-info").show()<CR>', opts)
          set('n', '<localleader>pc', '<cmd>lua require("package-info").change_version()<CR>', opts)
        end,
      })
    end,
    config = function()
      local icons = require('userlib.icons')
      require('package-info').setup({
        colors = {
          up_to_date = '#3C4048', -- Text color for up to date package virtual text
          outdated = '#fc514e', -- Text color for outdated package virtual text
        },
        icons = {
          enable = true, -- Whether to display icons
          style = {
            up_to_date = icons.checkSquare, -- Icon for up to date packages
            outdated = icons.gitRemove, -- Icon for outdated packages
          },
        },
        autostart = true, -- Whether to autostart when `package.json` is opened
        hide_up_to_date = true, -- It hides up to date versions when displaying virtual text
        hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
        -- Can be `npm` or `yarn`. Used for `delete`, `install` etc...
        -- The plugin will try to auto-detect the package manager based on
        -- `yarn.lock` or `package-lock.json`. If none are found it will use the
        -- provided one,                              if nothing is provided it will use `yarn`
        package_manager = 'pnpm',
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPost',
    enabled = false,
    opts = {
      max_lines = 3,
      mode = 'cursor',
      min_window_height = 5,
    },
    keys = {
      {
        '<leader>fc',
        '<cmd>lua require("treesitter-context").go_to_context()<cr>',
        desc = 'Treesitter Context: Go to context',
      },
    },
    config = function(_, opts)
      require('treesitter-context').setup(opts)
      vim.cmd([[hi TreesitterContextBottom gui=underline guisp=Grey]])
    end,
  },
})
