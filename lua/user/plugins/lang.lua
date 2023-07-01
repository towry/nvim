local plug = require('libs.runtime.pack').plug
local au = require('libs.runtime.au')

plug({
  {
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
    keys = {
      -- { "<Enter>",    desc = "Init Increment selection" },
      -- { "<Enter>",    desc = "node node incremental selection",      mode = "x" },
      { "<BS>", desc = "Decrement selection", mode = "x" },
      { '<leader>cr', desc = 'Smart rename/nvim-treesitter-refactor' },
    },
    dependencies = {
      "windwp/nvim-ts-autotag",
      'yioneko/nvim-yati',
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        init = function()
          -- PERF: no need to load the plugin, if we only need its queries for mini.ai
          local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
          local opts = require("lazy.core.plugin").values(plugin, "opts", false)
          local enabled = false
          if opts.textobjects then
            for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
              if opts.textobjects[mod] and opts.textobjects[mod].enable then
                enabled = true
                break
              end
            end
          end
          if not enabled then
            require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
          end
        end,
      },
      'nvim-treesitter/nvim-treesitter-refactor',
      -- setting the commentstring option based on the cursor location in the file. The location is checked via treesitter queries.
      -- Vue files can have many different sections, each of which can have a different style for comments.
      'JoosepAlviste/nvim-ts-context-commentstring',
      'HiPhish/nvim-ts-rainbow2',
      -- vai to select current context!
      -- 'kiyoon/treesitter-indent-object.nvim',
    },
    init = function()
      vim.opt.smartindent = false
      vim.api.nvim_create_augroup('_ts_file_opened', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
        group = '_ts_file_opened',
        nested = true,
        callback = function(args)
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
          if not (vim.fn.expand "%" == "" or buftype == "nofile") then
            -- remove this event.
            vim.api.nvim_del_augroup_by_name("_ts_file_opened")
            --- wait for other plugins has ready.
            vim.defer_fn(function()
              vim.schedule(function()
                vim.cmd('Lazy load nvim-treesitter')
              end)
            end, 2)
          end
        end,
      })
    end,
    config = function()
      local Buffer = require('libs.runtime.buffer')
      local disabled = function(_lang, bufnr)
        --- must after buffer is read and loaded, otherwise some option is not available.
        local ft = vim.api.nvim_get_option_value("filetype", {
          buf = bufnr,
        })
        if vim.tbl_contains(vim.cfg.lang__treesitter_plugin_disable_on_filetypes or {}, ft) then
          return true
        end
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })
        if buftype ~= '' then return true end
        -- great than 100kb or lines great than 20000
        return vim.api.nvim_buf_line_count(bufnr) > 20000 or Buffer.getfsize(bufnr) > 100000
      end
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.configs').setup({
        -- parser_install_dir = parser_install_dir,
        ensure_installed = vim.cfg.lang__treesitter_ensure_installed, -- one of "all", or a list of languages
        sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
        auto_install = false,
        ignore_install = { 'all' }, -- list of parsers to ignore installing
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
            --TODO: fix me.
            -- init_selection = "<Enter>",
            -- node_incremental = "<Enter>",
            scope_incremental = false,
            node_decremental = "<BS>",
          },
        },
        indent = {
          enable = not vim.cfg.lang__treesitter_plugin_yati,
          disable = disabled,
        },
        yati = {
          -- https://github.com/yioneko/nvim-yati
          enable = vim.cfg.lang__treesitter_plugin_yati,
          disable = disabled,
          default_lazy = true,
          default_fallback = 'auto',
          -- if ts.indent is truee, use below to suppress conflict warns.
          suppress_conflict_warning = true,
        },
        context_commentstring = {
          enable = vim.cfg.lang__treesitter_plugin_context_commentstring,
        },
        rainbow = {
          disable = disabled,
          enable = vim.cfg.lang__treesitter_plugin_rainbow,
          -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
          query = 'rainbow-parens',
          -- Highlight the entire buffer all at once
          strategy = require('ts-rainbow').strategy.global,
          max_file_lines = 8000,
        },
        refactor = {
          --- cause slowness.
          highlight_definitions = {
            is_supported = function(lang)
              local queries = require("nvim-treesitter.query")
              return not disabled(lang, vim.api.nvim_get_current_buf()) and queries.has_locals(lang)
            end,
            enable = false,
            -- Set to false if you have an `updatetime` of ~100.
            clear_on_cursor_move = true,
          },
          highlight_current_scope = {
            enable = false,
            is_supported = function(lang)
              local queries = require("nvim-treesitter.query")
              return not disabled(lang, vim.api.nvim_get_current_buf()) and queries.has_locals(lang)
            end,
          },
          smart_rename = {
            enable = false,
            keymaps = {
              smart_rename = '<leader>cr',
            },
          },
          navigation = {
            enable = false,
            keymaps = {
              -- goto_definition = "gd",
              -- list_definitions = "gnD",
              -- list_definitions_toc = "gO",
              -- goto_next_usage = "<a-*>",
              -- goto_previous_usage = "<a-#>",
            },
          },
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
          select = {
            disable = disabled,
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          swap = {
            enable = false,
            swap_next = {
              -- FIXME: keymap
              -- ["<S-~>"] = "@parameter.inner",
            },
          },
        },
        textsubjects = {
          disable = disabled,
          -- has issues.
          enable = vim.cfg.lang__treesitter_plugin_textsubjects,
          lookahead = false,
          keymaps = {
            ['<cr>'] = 'textsubjects-smart', -- works in visual mode
          },
        },
      })
    end
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
    }
  },

  {
    'echasnovski/mini.comment',
    keys = {
      {
        'gc',
        mode = { 'n', 'v' }
      },
      {
        'gcc',
        mode = { 'n', 'v' }
      },
    },
    opts = {

    }
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
        ']td', "<cmd>lua require('todo-comments').jump_next()<CR>", desc = 'Jump to next todo',
      },
      {
        '[td', "<cmd>lua require('todo-comments').jump_prev()<CR>", desc = 'Jump to next todo',
      }
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
    }
  },

  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && npm install',
    init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
    ft = { 'markdown' },
  },

  {
    'vuki656/package-info.nvim',
    event = 'BufEnter package.json',
    config = function()
      local icons = require('libs.icons')
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
        hide_unstable_versions = true, -- It hides unstable versions from version list e.g next-11.1.3-canary3
        -- Can be `npm` or `yarn`. Used for `delete`, `install` etc...
        -- The plugin will try to auto-detect the package manager based on
        -- `yarn.lock` or `package-lock.json`. If none are found it will use the
        -- provided one,                              if nothing is provided it will use `yarn`
        package_manager = 'npm',
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    enabled = true,
    opts = {
      max_lines = 3,
      mode = "cursor"
    },
    keys = {
      {
        '[c', '<cmd>lua require("treesitter-context").go_to_context()<cr>', desc = 'Treesitter Context: Go to context'
      }
    },
    config = function(_, opts)
      require('treesitter-context').setup(opts)
      vim.cmd([[hi TreesitterContextBottom gui=underline guisp=Grey]])
    end
  },
})
