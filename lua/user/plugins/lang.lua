local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')

plug({
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  event = 'VeryLazy',
  enabled = vim.cfg.lang__treesitter_next,
  cond = not vim.cfg.runtime__starts_as_gittool,
  config = function()
    require('nvim-treesitter').setup({
      ensure_install = vim.cfg.lang__treesitter_ensure_installed,
      auto_install = vim.cfg.lang_treesitter_auto_install,
      ignore_install = { 'comment' },
    })
    vim.treesitter.language.register('tsx', 'typescriptreact')
    vim.treesitter.language.register('markdown', 'mdx')
  end,
  init = function()
    vim.api.nvim_create_augroup('treesitter_start', { clear = true })
    vim.api.nvim_create_autocmd('User', {
      group = 'treesitter_start',
      pattern = 'TreeSitterStart',
      callback = function(ctx)
        local buf = ctx.data.bufnr
        vim.bo[buf].indentexpr = [[v:lua.require('nvim-treesitter').indentexpr()]]
      end,
    })
  end,
})

plug({
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  version = '0.9.2',
  build = function()
    if #vim.api.nvim_list_uis() == 0 then
      -- update sync if running headless
      vim.cmd.TSUpdateSync()
    else
      -- otherwise update async
      vim.cmd.TSUpdate()
    end
  end,
  event = 'VeryLazy',
  enabled = not vim.cfg.lang__treesitter_next,
  cond = not vim.cfg.runtime__starts_as_gittool,
  dependencies = {
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
        if not enabled then
          require('lazy.core.loader').disable_rtp_plugin('nvim-treesitter-textobjects')
        end
      end,
    },
  },
  config = function()
    local disabled = function(_lang, bufnr)
      return vim.b[bufnr].is_big_file
    end
    local install_path = vim.fn.stdpath('data') .. '/site/treesitter-master'
    vim.opt.runtimepath:append(install_path)
    require('nvim-treesitter.install').prefer_git = true
    require('nvim-treesitter.configs').setup({
      parser_install_dir = install_path,
      ensure_installed = vim.cfg.lang__treesitter_ensure_installed,
      highlight = {
        disable = disabled,
        additional_vim_regex_highlighting = false,
      },
      incremental_selection = {
        enable = true,
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
      textobjects = {
        move = {
          disable = disabled,
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = { query = '@class.outer', desc = 'Next class start' },
            --
            -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
            -- [']o'] = '@loop.*',
            [']o'] = { query = { '@loop.inner', '@loop.outer' } },
            --
            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
            [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
          goto_next = {
            [']t'] = '@conditional.outer',
          },
          goto_previous = {
            ['[t'] = '@conditional.outer',
          },
        },
        swap = {
          enable = false,
        },
      }, -- end textobjects
    })
  end,
})

local fts = {
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
}
plug({
  {
    'NvChad/nvim-colorizer.lua',
    opts = {
      filetypes = fts,
      user_default_options = {
        mode = 'background',
        tailwind = true, -- Enable tailwind colors
      },
    },
    init = function()
      vim.api.nvim_create_augroup('load_colorizer_', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = 'load_colorizer_',
        pattern = fts,
        callback = function()
          if vim.b.is_big_file then
            return
          end
          require('userlib.runtime.utils').load_plugins('nvim-colorizer.lua')
          vim.api.nvim_clear_autocmds({
            event = 'FileType',
            group = 'load_colorizer_',
          })
        end,
      })
    end,
  },

  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    cond = not vim.cfg.runtime__starts_as_gittool,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },

  {
    'numToStr/Comment.nvim',
    cond = not vim.cfg.runtime__starts_as_gittool,
    event = { 'BufReadPost', 'BufNewFile' },
    opts = function()
      local pre_hook = nil
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
          if vim.b.is_big_file then
            return
          end
          if not pre_hook then
            pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
          end
          return pre_hook(ctx)
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
    'iamcco/markdown-preview.nvim',
    build = 'cd app && npm install && rm -f package-lock.json && git restore .',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
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
    enabled = vim.cfg.lang__treesitter_next,
    opts = {
      max_lines = 2,
      mode = 'cursor',
      min_window_height = 4,
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
      -- vim.cmd([[hi TreesitterContextBottom gui=underline guisp=Grey]])
    end,
  },
})
