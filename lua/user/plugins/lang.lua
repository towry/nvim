local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')

plug({
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  lazy = false,
  config = function()
    require('nvim-treesitter').setup({
      ensure_install = vim.cfg.lang__treesitter_ensure_installed,
    })
    vim.treesitter.language.register('tsx', 'typescriptreact')
  end,
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'TreeSitterStart',
      callback = function()
        if vim.b.treesitter_disable then return end
        vim.opt_local.indentexpr = [[v:lua.require('nvim-treesitter').indentexpr()]]
      end
    })
  end
})

plug({
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
    'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
  },

  {
    'numToStr/Comment.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
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
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
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
        signs = false,     -- show icons in the signs column
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
          before = '',                     -- "fg" or "bg" or empty
          -- keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
          keyword = 'wide',                -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
          after = '',                      -- "fg" or "bg" or empty
          pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
          comments_only = true,            -- uses treesitter to match keywords in comments only
          max_line_len = 1500,             -- ignore lines longer than this
          exclude = {},                    -- list of file types to exclude highlighting
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
    build = 'cd app && npm install && rm -f package-lock.json && git restore .',
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
          outdated = '#fc514e',   -- Text color for outdated package virtual text
        },
        icons = {
          enable = true,                    -- Whether to display icons
          style = {
            up_to_date = icons.checkSquare, -- Icon for up to date packages
            outdated = icons.gitRemove,     -- Icon for outdated packages
          },
        },
        autostart = true,               -- Whether to autostart when `package.json` is opened
        hide_up_to_date = true,         -- It hides up to date versions when displaying virtual text
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
