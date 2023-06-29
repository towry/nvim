local pack = require('libs.runtime.pack')

---- core
pack.plug({
  {
    'nvim-lua/plenary.nvim',
  },
  {
    'nvim-tree/nvim-web-devicons',
  },
  { 'nvim-lua/popup.nvim' },
  {
    'MunifTanjim/nui.nvim',
  },
  {
    'tpope/vim-repeat',
    keys = { '.' },
  },
  {
    'echasnovski/mini.trailspace',
    event = require('libs.runtime.au').user_autocmds.FileOpenedAfter_User,
    config = true,
  }
})

---dressing
pack.plug({
  'stevearc/dressing.nvim',
  lazy = true,
  event = 'User LazyUIEnter',
  config = function()
    require('dressing').setup({
      input = {
        -- Set to false to disable the vim.ui.input implementation
        enabled = true,
        -- Default prompt string
        default_prompt = 'Input:',
        -- Can be 'left', 'right', or 'center'
        prompt_align = 'left',
        -- When true, <Esc> will close the modal
        insert_only = true,
        -- When true, input will start in insert mode.
        start_in_insert = true,
        -- These are passed to nvim_open_win
        anchor = 'SW',
        border = 'rounded',
        -- 'editor' and 'win' will default to being centered
        relative = 'cursor',
        -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        prefer_width = 10,
        width = nil,
        -- min_width and max_width can be a list of mixed types.
        -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
        max_width = { 140, 0.9 },
        min_width = { 10, 0.1 },
        win_options = {
          -- Window transparency (0-100)
          winblend = 0,
          -- Change default highlight groups (see :help winhl)
          winhighlight = '',
        },
        -- Set to `false` to disable
        mappings = {
          n = {
            ['<Esc>'] = 'Close',
            ['<CR>'] = 'Confirm',
          },
          i = {
            ['<C-c>'] = 'Close',
            ['<CR>'] = 'Confirm',
            ['<Up>'] = 'HistoryPrev',
            ['<Down>'] = 'HistoryNext',
          },
        },
        override = function(conf)
          -- This is the config that will be passed to nvim_open_win.
          -- Change values here to customize the layout
          return conf
        end,
        -- see :help dressing_get_config
        get_config = nil,
      },
      select = {
        -- Set to false to disable the vim.ui.select implementation
        enabled = true,
        -- Priority list of preferred vim.select implementations
        backend = { 'telescope', 'nui', 'fzf', 'builtin' },
        -- Options for nui Menu
        nui = {
          position = {
            row = 1,
            col = 0,
          },
          size = nil,
          relative = 'cursor',
          border = {
            style = 'rounded',
            text = {
              top_align = 'right',
            },
          },
          buf_options = {
            swapfile = false,
            filetype = 'DressingSelect',
          },
          max_width = 80,
          max_height = 40,
        },
        -- Options for built-in selector
        builtin = {
          -- These are passed to nvim_open_win
          wnchor = 'SW',
          border = 'rounded',
          -- 'editor' and 'win' will default to being centered
          relative = 'cursor',
          win_options = {
            -- Window transparency (0-100)
            winblend = 5,
            -- Change default highlight groups (see :help winhl)
            winhighlight = '',
          },
          -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          -- the min_ and max_ options can be a list of mixed types.
          -- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
          width = nil,
          max_width = { 140, 0.8 },
          min_width = { 10, 0.2 },
          height = nil,
          max_height = 0.9,
          min_height = { 2, 0.05 },
          -- Set to `false` to disable
          mappings = {
            ['<Esc>'] = 'Close',
            ['<C-c>'] = 'Close',
            ['<CR>'] = 'Confirm',
          },
          override = function(conf)
            -- This is the config that will be passed to nvim_open_win.
            -- Change values here to customize the layout
            return conf
          end,
        },
        -- see :help dressing_get_config
        get_config = function(opts)
          if opts.kind == 'codeaction' then
            return {
              backend = 'builtin',
              nui = {
                relative = 'cursor',
                max_width = 80,
                min_height = 2,
              },
            }
          end
        end,
      },
    })
  end,
})

--- legendary
pack.plug({
  'mrjones2014/legendary.nvim',
  dependencies = {
    'dressing.nvim',
    -- used for frecency sort
    'kkharji/sqlite.lua',
  },
  config = function()
    local function my_formatter(item)
      local default_columns = require('legendary.ui.format').default_format(item)
      local swap = default_columns[2]
      default_columns[2] = default_columns[3]
      default_columns[3] = swap
      -- remove the key|command column.
      table.remove(default_columns, 3)
      return default_columns
    end

    local lg = require("legendary");
    local au = require("libs.runtime.au")
    lg.setup({
      funcs = require('libs.legendary.funcs.migrate'),
      commands = require("libs.legendary.commands.migrate"),
      -- autocmds =
      default_item_formatter = my_formatter,
      include_builtin = false,
      include_legendary_cmds = false,
      default_opts = {
        keymaps = { silent = true, noremap = true },
      },
      select_prompt = " ⚒ ",
      icons = {
        fn = " ",
        command = " ",
        key = " ",
      },
    })

    au.do_useraucmd(au.user_autocmds.LegendaryConfigDone_User)
  end,
})

--- which-key
pack.plug({
  'folke/which-key.nvim',
  keys = { "<leader>", "<C-f>" },
  cmd = { 'WhichKey' },
  config = function()
    local wk = require('which-key')
    wk.setup({
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        spelling = {
          enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
        presets = {
          operators = true, -- adds help for operators like d, y, ...
          motions = true, -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = false, -- default bindings on <c-w>, already taken care by hydra.
          nav = false, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
      },
      operators = { gc = 'Comments' },
      key_labels = {
        ['<space>'] = 'SPC',
        ['<cr>'] = 'RET',
        ['<tab>'] = 'TAB',
      },
      icons = {
        breadcrumb = '»', -- symbol used in the command line area that shows your active key combo
        separator = ' ', -- symbol used between a key and it's label
        group = '  ', -- symbol prepended to a group
      },
      popup_mappings = {
        scroll_down = '<c-d>', -- binding to scroll down inside the popup
        scroll_up = '<c-u>', -- binding to scroll up inside the popup
      },
      window = {
        border = 'none', -- none, single, double, shadow
        position = 'bottom', -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
        winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = 'left', -- align columns left, center or right
      },
      ignore_missing = false,
      hidden = { '<CR>', '^:', '^ ', '^call ', '^lua ' }, -- hide mapping boilerplate
      show_help = false, -- show a help message in the command line for using WhichKey
      show_keys = true, -- show the currently pressed key and its label as a message in the command line
      triggers = 'auto', -- automatically setup triggers
      triggers_nowait = {
        -- marks
        '`',
        "'",
        'g`',
        "g'",
        "gg",
        "G",
        -- registers
        '"',
        '<c-r>',
        -- spelling
        'z=',
      },
      triggers_blacklist = {
        -- list of mode / prefixes that should never be hooked by WhichKey
        -- this is mostly relevant for keymaps that start with a native binding
        i = { 'j', 'k' },
        v = { 'j', 'k' },
      },
    })

    ---Groups
    wk.register({
      f = {
        name = 'Profject files',
      },
      r = {
        name = 'Recent files',
      },
      s = {
        name = 'Grep search content',
      }
    }, {
      prefix = '<C-f>'
    })
    wk.register({
      ['<space>'] = {
        name = 'Shortcuts',
      },
      c = {
        name = 'Code',
      },
      e = {
        name = 'Explorer',
      },
      w = {
        name = 'Git workspace',
      },
      ['/'] = {
        name = 'Outline|Terms',
      },
      s = {
        name = 'Search|Replace',
      },
      t = {
        name = 'Tools',
      },
      z = {
        name = 'Extended..',
      },
      g = {
        name = 'Git',
      },
      b = {
        name = "Buffers"
      },
      m = {
        name = 'Motion|Modify',
        j = {
          name = 'Join & Split'
        }
      },
      r = {
        name = 'Debugger|Runner',
        f = {
          name = 'Sniprun',
        },
        o = {
          name = "Overseer Runner"
        },
        t = {
          name = 'Test runner',
        }
      }
    }, {
      prefix = '<leader>'
    })

    wk.register({
      g = {
        d = {
          name = 'Go to definition|...',
          f = {
            name = 'Go to definition in file|...',
            x = {
              'Go to definition in splited file',
            },
            v = {
              'Go to definition in vertical splited file',
            },
          }
        }
      }
    })
  end,
})

---============================================================
--- yanky
local function setup_yanky_legendary()
  local has_legendary = require('libs.runtime.utils').has_plugin('legendary.nvim')
  if not has_legendary then return end
  local legendary = require('legendary')

  legendary.func({
    function() require('telescope').extensions.yank_history.yank_history({}) end,
    description = 'Paste from yanky',
  })
  legendary.keymaps({
    { '<Plug>(YankyCycleForward)', description = 'Yanky/paste cycle forward ' },
    { '<Plug>(YankyCycleBackward)', description = 'Ynky/paste cycle backward ' },
  })
end

pack.plug({
  -- better yank
  'gbprod/yanky.nvim',
  keys = {
    {
      'y', '<Plug>(YankyYank)', mode = { 'n', 'x', }, desc = 'Yanky yank',
    },
    {
      'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x', }, desc = 'Yanky put after',
    },
    {
      'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x', }, desc = 'Yanky put before',
    },
    {
      'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x', }, desc = 'Yanky gput after',
    },
    {
      'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x', }, desc = 'Yanky gput before',
    },
  },
  config = function()
    require('yanky').setup({
      highlight = {
        timer = 150,
      },
      ring = {
        history_length = 30,
        storage = 'shada',
      },
    })
  end,
  init = function()
    local au = require('libs.runtime.au')
    au.define_autocmds({
      {
        "User",
        {
          group = "setup_yanky_lg",
          pattern = au.user_autocmds.LegendaryConfigDone,
          once = true,
          callback = function()
            setup_yanky_legendary()
          end,
        }
      }
    })
  end,
})
