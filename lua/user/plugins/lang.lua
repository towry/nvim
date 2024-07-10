local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')

local treesitter_parsers_path = vim.fn.stdpath('data') .. '/site'

plug({
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  event = 'VeryLazy',
  enabled = vim.cfg.lang__treesitter_next,
  cond = not vim.cfg.runtime__starts_as_gittool,
  config = function()
    vim.opt.runtimepath:prepend(treesitter_parsers_path)

    require('nvim-treesitter').setup({
      install_dir = treesitter_parsers_path,
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
        -- FIXME: tree sitter indent not working well on some ft like nix.
        local buf = ctx.data.bufnr
        if vim.b[buf].indentexpr == 0 then
          return
        end
        vim.bo[buf].indentexpr = [[v:lua.require('nvim-treesitter').indentexpr()]]
      end,
    })
  end,
})

plug({
  -- 'pze/nvim-treesitter-textobjects',
  -- dev = true,
  -- branch = 'fix_main',
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter', branch = 'main' },
  },
  init = function()
    local set = require('userlib.runtime.keymap').set

    local select_maps = {
      ['oam'] = '@function.outer',
      ['oim'] = '@function.inner',
      ['oap'] = '@parameter.outer',
      ['oip'] = '@parameter.inner',
      -- class
      ['oac'] = '@class.outer',
      ['oic'] = '@class.inner',
    }
    local move_maps = {
      goto_next_start = {
        [']om'] = '@function.outer',
        --- next start of class
        [']oc'] = '@class.outer',
        --- next start of loop
        [']oo'] = '@loop.outer',
      },
      goto_next_end = {
        [']oM'] = '@function.outer',
        [']oC'] = '@class.outer',
        [']oO'] = '@loop.outer',
      },
      goto_previous_start = {
        ['[om'] = '@function.outer',
        ['[oc'] = '@class.outer',
        ['[oo'] = '@loop.outer',
      },
      goto_previous_end = {
        ['[oM'] = '@function.outer',
        ['[oC'] = '@class.outer',
        ['[oO'] = '@loop.outer',
      },
      goto_next = {
        --- goto next either start or end of select.
        [']od'] = '@conditional.outer',
        --- goto previous either start or end of select.
        ['[od'] = '@conditional.outer',
      },
    }

    for method, maps in pairs(move_maps) do
      for input, cap in pairs(maps) do
        set({ 'o', 'x', 'n' }, input, function()
          require('nvim-treesitter-textobjects.move')[method](cap, 'textobjects')
        end, {
          desc = 'TS.move: ' .. method,
        })
      end
    end

    for input, cap in pairs(select_maps) do
      set({ 'x', 'o' }, input, function()
        require('nvim-treesitter-textobjects.select').select_textobject(cap, 'textobjects')
      end)
    end
  end,

  config = function()
    require('nvim-treesitter-textobjects').setup({
      move = {
        -- whether to set jumps in the jumplist
        set_jumps = true,
      },
      select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V', -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true of false
      include_surrounding_whitespace = false,
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
    enabled = false,
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
    event = 'User FileOpenedAfter',
    enabled = false,
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
    keys = {
      {
        '<localleader>cd',
        ':Neogen<cr>',
        noremap = true,
        desc = 'Neogen',
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function(_, opts)
      require('neogen').setup(vim.tbl_deep_extend('force', {
        enabled = true,
      }, opts or {}))
    end,
  },

  {
    'kkoomen/vim-doge',
    enabled = false,
    build = ':call doge#install()',
    cmd = { 'DogeGenerate' },
    event = 'VeryLazy',
    keys = {
      {
        '<localleader>cd',
        '<Plug>(doge-generate)',
        noremap = true,
        desc = 'Doge doc gen',
      },
    },
    config = function()
      vim.g.doge_buffer_mappings = 0
      vim.g.doge_enable_mappings = 0
      vim.g.doge_doc_standard_python = 'google'
    end,
    init = au.schedule_lazy(function()
      _G.Ty.dogedoc_standards = function()
        return {
          'google',
        }
      end

      require('userlib.legendary').register('doge', function(lg)
        lg.funcs({
          {
            function()
              vim.ui.input({
                prompt = 'Doc standard: ',
                completion = 'custom,v:lua.Ty.dogedoc_standards',
              }, function(input)
                if vim.trim(input or '') == '' then
                  return
                end
                vim.api.nvim_command('DogeGenerate ' .. input)
                vim.notify('DogeGenerate ' .. input, vim.log.levels.INFO)
              end)
            end,
            description = 'DogeGenerate generate doc with standards',
          },
        })
      end)
    end),
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
      line_numbers = true,
      min_window_height = 4,
    },
    keys = {
      {
        '<localleader>gc',
        '<cmd>lua require("treesitter-context").go_to_context()<cr>',
        desc = 'Treesitter Context: Go to context',
      },
    },
    config = function(_, opts)
      require('treesitter-context').setup(opts)
      -- vim.cmd([[hi TreesitterContextBottom gui=underline guisp=Grey]])
    end,
  },

  {
    'ziglang/zig.vim',
    ft = { 'zig', 'zir' },
  },
})

plug({
  'pze/amber.vim',
  filetypes = { 'amber' },
})

plug({
  'alaviss/nim.nvim',
  ft = 'nim',
})
