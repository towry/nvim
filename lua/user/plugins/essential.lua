local au = require('userlib.runtime.au')
local pack = require('userlib.runtime.pack')
local function t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

---- core
pack.plug({
  {
    'echasnovski/mini.pick',
    config = function()
      require('mini.pick').setup({ window = { config = { border = 'single' } } })
    end,
    init = au.schedule_lazy(function()
      if vim.cfg.ui__input_select_provider ~= 'mini' then
        return
      end
      vim.ui.select = require('mini.pick').ui_select
    end),
  },
  { 'echasnovski/mini.extra' },
  {
    'echasnovski/mini.cursorword',
    event = 'BufReadPost',
    enabled = not vim.cfg.edit__use_coc,
    opts = {
      delay = 350,
    },
  },
  {
    vscode = true,
    'nvim-lua/plenary.nvim',
  },
  {
    'tpope/vim-dispatch',
    keys = {},
    cmd = {
      'Dispatch',
      'Make',
      'Focus',
      'FocusDispatch',
      'Start',
      'Copen',
      'AbortDispatch',
    },
    config = function() end,
    init = function()
      vim.g.dispatch_no_maps = 1
      vim.g.dispatch_no_tmux_make = 1 -- do not use tmux strategy in tmux.
    end,
  },
  {
    'nvim-tree/nvim-web-devicons',
  },
  { 'nvim-lua/popup.nvim' },
  {
    'grapp-dev/nui-components.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
  },
  {
    'tpope/vim-repeat',
    vscode = true,
    keys = { '.' },
  },
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
        border = vim.cfg.ui__float_border,
        -- 'editor' and 'win' will default to being centered
        relative = 'editor',
        -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        prefer_width = 50,
        width = nil,
        -- min_width and max_width can be a list of mixed types.
        -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },
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
        enabled = vim.cfg.ui__input_select_provider == 'dressing' and true or false,
        -- Priority list of preferred vim.select implementations
        backend = vim.cfg.runtime__starts_as_gittool and { 'builtin' } or { 'fzf_lua', 'telescope', 'nui', 'builtin' },
        -- Options for nui Menu
        nui = {
          position = {
            row = 1,
            col = 0,
          },
          size = nil,
          relative = 'cursor',
          border = {
            style = 'single',
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
        fzf_lua = {
          winopts = {
            fullscreen = false,
            height = 0.30,
            width = 0.80,
          },
          fzf_opts = {
            ['--no-hscroll'] = '',
            ['--delimiter'] = '[\\.\\s]',
            ['--with-nth'] = '3..',
          },
        },
        telescope = (function()
          if vim.cfg.runtime__starts_as_gittool then
            return nil
          end
          return require('userlib.telescope.themes').get_dropdown()
        end)(),
        -- Options for built-in selector
        builtin = {
          -- These are passed to nvim_open_win
          wnchor = 'SW',
          border = 'single',
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
          -- NOTE: code action ui
          if opts.kind == 'codeaction' then
            return {
              backend = 'nui',
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
  cmd = { 'Legendary', 'LegendaryRepeat' },
  keys = {
    {
      '<leader>;',
      '<cmd>LegendaryRepeat<cr>',
      desc = 'Legendary repeat last',
    },
    {
      '<localleader>p',
      '<cmd>Legendary<cr>',
      desc = 'Legendary',
    },
  },
  config = function()
    local function my_formatter(item)
      local default_columns = require('legendary.ui.format').default_format(item)
      local swap = default_columns[2]
      default_columns[2] = default_columns[3]
      default_columns[3] = swap
      -- remove the key|command column.
      -- table.remove(default_columns, 3)
      return default_columns
    end

    local lg = require('legendary')
    lg.setup({
      funcs = require('userlib.legendary.funcs.migrate'),
      commands = require('userlib.legendary.commands.migrate'),
      -- autocmds =
      default_item_formatter = my_formatter,
      include_builtin = true,
      include_legendary_cmds = false,
      default_opts = {
        keymaps = { silent = true, noremap = true },
      },
      sort = {
        most_recent_first = true,
        -- sort user-defined items before built-in items
        user_items_first = true,
        frecency = {
          -- the directory to store the database in
          db_root = string.format('%s/legendary/', vim.fn.stdpath('data')),
          -- the maximum number of timestamps for a single item
          -- to store in the database
          max_timestamps = 10,
        },
      },
      -- col_separator_char = '#',
      select_prompt = 'Legendary: ',
      icons = {
        fn = '',
        command = '',
        key = '',
      },
      extensions = {
        diffview = true,
      },
      log_level = 'error',
    })
  end,
})

---============================================================
--- yanky
local function setup_yanky_legendary()
  local has_legendary = require('userlib.runtime.utils').has_plugin('legendary.nvim')
  if not has_legendary then
    return
  end
  local legendary = require('legendary')

  legendary.func({
    function()
      require('telescope').extensions.yank_history.yank_history({})
    end,
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
  enabled = false,
  keys = {
    {
      '<localleader>lp',
      ':Telescope yank_history<cr>',
      silent = true,
      noremap = true,
      desc = 'List yanky pastes',
    },
    {
      '<Leader>mpn',
      '<Plug>(YankyPreviousEntry)',
      noremap = true,
      nowait = true,
    },
    {
      '<Leader>mpp',
      '<Plug>(YankyNextEntry)',
      noremap = true,
      nowait = true,
    },
    {
      'y',
      '<Plug>(YankyYank)',
      mode = { 'n', 'x' },
      desc = 'Yanky yank',
    },
    {
      '<C-v>',
      function()
        vim.cmd.stopinsert()
        vim.fn.feedkeys(t('p'))
      end,
      mode = { 'i' },
      desc = 'Yanky put after in insert',
    },
    {
      'p',
      '<Plug>(YankyPutAfter)',
      mode = { 'n', 'x' },
      noremap = true,
      desc = 'Yanky put after',
    },
    {
      'cp',
      '<Plug>(YankyPutAfterCharwise)',
      mode = { 'n', 'x' },
      noremap = true,
      desc = 'Yanky put after charwise',
    },
    {
      'cP',
      '<Plug>(YankyPutBeforeCharwise)',
      mode = { 'n', 'x' },
      noremap = true,
      desc = 'Yanky put before charwise',
    },
    {
      'P',
      '<Plug>(YankyPutBefore)',
      mode = { 'n', 'x' },
      desc = 'Yanky put before',
    },
    {
      'gp',
      '<Plug>(YankyGPutAfter)',
      mode = { 'n', 'x' },
      desc = 'Yanky gput after',
    },
    {
      'gP',
      '<Plug>(YankyGPutBefore)',
      mode = { 'n', 'x' },
      desc = 'Yanky gput before',
    },
    {
      ']p',
      '<Plug>(YankyPutIndentAfterLinewise)',
      desc = 'Yanky put after with indent linewise',
    },
    {
      '[p',
      '<Plug>(YankyPutIndentBeforeLinewise)',
      desc = 'Yanky put before with indent linewise',
    },
    --- text objects
    {
      'lp',
      function()
        require('yanky.textobj').last_put()
      end,
      desc = 'Yanky Last put',
      mode = { 'x', 'o' },
    },
  },
  config = function()
    local mappings = require('yanky.telescope.mapping')
    local utils = require('yanky.utils')
    require('yanky').setup({
      highlight = {
        timer = 50,
      },
      picker = {
        telescope = {
          use_default_mappings = false,
          mappings = {
            default = mappings.put('p'),
            i = {
              ['<c-g>'] = mappings.put('p'),
              ['<c-k>'] = mappings.put('P'),
              ['<c-x>'] = mappings.delete(),
              ['<c-r>'] = mappings.set_register(utils.get_default_register()),
            },
          },
        },
      },
      --- cycle history when paste with shortcuts.
      ring = {
        --- number of items used for ring.
        history_length = 80,
        storage = 'shada',
      },
    })
    require('telescope').load_extension('yank_history')
  end,
  init = au.schedule_lazy(function()
    require('userlib.legendary').register('setup_yanky_lg', setup_yanky_legendary)
  end),
})

pack.plug({
  'ibhagwan/smartyank.nvim',
  opts = {
    tmux = { enabled = false },
    highlight = {
      enabled = false,
    },
  },
  event = 'User FileOpenedAfter',
})

pack.plug({
  'echasnovski/mini.clue',
  event = { 'CursorHold', 'CursorHoldI' },
  enabled = vim.cfg.plugin__whichkey_or_clue == 'clue',
  config = function()
    local miniclue = require('mini.clue')

    local opts = {
      window = {
        delay = 200,
        config = {
          width = 'auto',
        },
      },
      triggers = {
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },
        { mode = 'n', keys = '<LocalLeader>' },
        { mode = 'x', keys = '<LocalLeader>' },
        { mode = 'n', keys = '<Leader>z+' },
        { mode = 'n', keys = '<C-w>' },
        -- Built-in completion
        { mode = 'i', keys = '<C-x>' },
        { mode = 'i', keys = '<C-o>' },

        -- `g` key
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },

        -- Marks
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },

        -- Registers
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        -- `z` key
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
      },
      clues = {
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        -- miniclue.gen_clues.registers(),
        miniclue.gen_clues.z(),
        { mode = 'n', keys = '<Leader>a', desc = '+AI Assistant' },
        { mode = 'v', keys = '<Leader>a', desc = '+AI Assistant' },
        { mode = 'x', keys = '<Leader>a', desc = '+AI Assistant' },
        { mode = 'e', keys = '<Leader>e', desc = '+Edits' },
        { mode = 'n', keys = '<Leader>n', desc = '+Normal mode utils' },
        { mode = 'n', keys = '<Leader>q', desc = '+Quickfix|Loclist' },
        { mode = 'n', keys = '<LocalLeader>b', desc = '+Buffer' },
        { mode = 'n', keys = '<LocalLeader>c', desc = '+Code' },
        { mode = 'n', keys = 'ga', desc = '+TextChanges' },
        { mode = 'n', keys = 'gao', desc = '+Current word case change' },
        -- gh<key> for gitsigns.
        { mode = 'n', keys = '<Leader>g', desc = '+Git' },
        { mode = 'x', keys = '<Leader>g', desc = '+Git' },
        { mode = 'n', keys = '<Leader>f', desc = '+Finder' },
        { mode = 'x', keys = '<Leader>f', desc = '+Finder' },
        { mode = 'v', keys = '<Leader>f', desc = '+Finder' },
        { mode = 'n', keys = '<Leader>c', desc = '+Code' },
        { mode = 'x', keys = '<Leader>c', desc = '+Code' },
        { mode = 'v', keys = '<Leader>c', desc = '+Code' },
        { mode = 'n', keys = '<Leader>/', desc = '+Outline|Terms' },
        { mode = 'n', keys = '<Leader>v', desc = '+Trails' },
        { mode = 'n', keys = '<Leader>z', desc = '+Extended' },

        { mode = 'n', keys = '<Leader>m', desc = '+Motion' },
        { mode = 'n', keys = '<Leader>mj', desc = '+Join' },
        { mode = 'n', keys = '<Leader>mp', desc = '+Cycle Yanky paste' },
        { mode = 'n', keys = '<Leader>mpn', postkeys = '<Leader>mp', desc = 'Cycle paste yanky next' },
        { mode = 'n', keys = '<Leader>mpp', postkeys = '<Leader>mp', desc = 'Cycle paste yanky previous' },

        { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
        { mode = 'n', keys = '<Leader>p', desc = '+Projects' },
        { mode = 'n', keys = '<Leader>t', desc = '+Tools|Toggle' },
        { mode = 'x', keys = '<Leader>t', desc = '+Tools|Toggle' },
        { mode = 'n', keys = '<Leader>to', desc = 'Toggle options' },
        { mode = 'n', keys = '<Leader>w', desc = '+Workspace' },
        { mode = 'n', keys = '<Leader>s', desc = '+Search|Replace' },
        { mode = 'x', keys = '<Leader>s', desc = '+Search|Replace' },
        { mode = 'n', keys = '<Leader>sg', desc = '+Grep' },
        { mode = 'n', keys = '<Leader>r', desc = '+Runner|Debugger' },
        { mode = 'n', keys = '<LocalLeader>o', desc = '+Overseer' },
        ---
        { mode = 'n', keys = 'gh', desc = '+Gitsigns' },
        { mode = 'x', keys = 'gh', desc = '+Gitsigns' },
        --- windows
        miniclue.gen_clues.windows(),
        { mode = 'n', keys = '<C-w>a' },
        { mode = 'n', keys = '<C-w>m' },
        { mode = 'n', keys = '<C-w>x' },
        { mode = 'n', keys = '<C-w>=' },
        --- localleader
        { mode = 'n', keys = '<LocalLeader>f', desc = '+Grep' },
        vim.g.miniclues,
      },
    }
    miniclue.setup(opts)
  end,
  init = function()
    au.define_user_autocmd({
      pattern = 'WhichKeyRefresh',
      callback = function(ctx)
        local ok, miniclue = pcall(require, 'mini.clue')
        if not ok then
          return
        end
        vim.schedule(function()
          local data = ctx.data
          local buf = data.buffer
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          miniclue.ensure_buf_triggers(buf)
        end)
      end,
    })
  end,
})

pack.plug({
  'tversteeg/registers.nvim',
  name = 'registers',
  cmd = 'Registers',
  keys = {
    { '"', mode = { 'n', 'v' } },
    { '<C-R>', mode = 'i' },
  },
  opts = {
    window = {
      transparency = 10,
    },
  },
})

pack.plug({
  'gbprod/cutlass.nvim',
  vscode = true,
  event = 'User LazyUIEnter',
  opts = {
    cut_key = nil,
    override_del = true,
    exclude = {
      'ns',
    },
    registers = {
      select = 's',
      delete = 'd',
      change = 'c',
    },
  },
})
