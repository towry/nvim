local plug = require('userlib.runtime.pack').plug
local cmd = require('userlib.runtime.keymap').cmdstr
local au = require('userlib.runtime.au')

plug({
  {
    -- jump html tags.
    'harrisoncramer/jump-tag',
    vscode = true,
    keys = {
      {
        '[tp',
        cmd([[lua require('jump-tag').jumpParent()]]),
        desc = 'Jump to parent tag',
      },
      {
        '[tc',
        cmd([[lua require('jump-tag').jumpChild()]]),
        desc = 'Jump to child tag',
      },
      {
        '[t]',
        cmd([[lua require('jump-tag').jumpNextSibling()]]),
        desc = 'Jump to next tag',
      },
      {
        '[t[',
        cmd([[lua require('jump-tag').jumpPrevSibling()]]),
        desc = 'Jump to prev tag',
      },
    },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    'pze/mini.ai',
    vscode = true,
    -- disabled due to not compatible with nvim-treesitter#1.0
    enabled = true,
    dev = false,
    -- event = au.user_autocmds.FileOpenedAfter_User,
    event = { 'CursorHold' },
    opts = function()
      local ai = require('mini.ai')
      return {
        search_method = 'cover_or_nearest',
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }, {
            use_nvim_treesitter = false,
          }),
          f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {
            use_nvim_treesitter = false,
          }),
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {
            use_nvim_treesitter = false,
          }),
        },
      }
    end,
    config = function(_, opts)
      require('mini.ai').setup(opts)
    end,
  },

  {
    'kylechui/nvim-surround',
    vscode = true,
    version = '*',
    event = au.user_autocmds.FileOpened_User,
    opts = {
      keymaps = {
        delete = 'dz',
      },
    },
  },

  {
    -- https://github.com/Wansmer/treesj
    'Wansmer/treesj',
    vscode = true,
    keys = {
      {
        '<leader>mjt',
        '<cmd>lua require("treesj").toggle()<cr>',
        desc = 'Toggle',
      },
      {
        '<leader>mjs',
        '<cmd>lua require("treesj").split()<cr>',
        desc = 'Split',
      },
      {
        '<leader>mjj',
        '<cmd>lua require("treesj").join()<cr>',
        desc = 'Join',
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      use_default_keymaps = false,
    },
  },
  ---prevent the cursor from moving when using shift and filter actions.
  { 'gbprod/stay-in-place.nvim', config = true, event = au.user_autocmds.FileOpenedAfter_User },

  {
    'folke/flash.nvim',
    vscode = true,
    event = 'User LazyUIEnterOncePost',
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        '<C-s><C-s>',
        mode = { 'n' },
        nowait = true,
        function()
          require('userlib.workflow.flashs').jump_to_line()
        end,
        desc = 'Flash jump to line',
      },
      {
        '[s',
        mode = { 'n', 'o' },
        function()
          require('flash').jump({
            search = { forward = false, wrap = false, multi_window = false },
            label = {
              uppercase = false,
            },
          })
        end,
        desc = 'Flash backward search',
      },
      {
        ']s',
        mode = { 'n', 'o' },
        function()
          require('flash').jump({
            search = { forward = true, wrap = false, multi_window = false },
            label = {
              uppercase = false,
            },
          })
        end,
        desc = 'Flash forward search',
      },
      {
        '.s',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        '<C-o>o',
        mode = 'i',
        desc = 'o after flash',
        function()
          require('userlib.workflow.flashs').jump_to_line({
            action = function(match)
              vim.api.nvim_set_current_win(match.win)
              vim.api.nvim_win_set_cursor(match.win, match.pos)
              vim.cmd('normal! o')
            end,
          })
        end,
      },
      {
        '<C-o>O',
        mode = 'i',
        desc = 'O after flash in insert mode',
        function()
          require('userlib.workflow.flashs').jump_to_line({
            action = function(match)
              vim.api.nvim_set_current_win(match.win)
              vim.api.nvim_win_set_cursor(match.win, match.pos)
              vim.cmd('normal! O')
            end,
          })
        end,
      },
      {
        '<C-s>v',
        mode = { 'i', 'n' },
        desc = 'Copy after flash',
        function()
          require('userlib.workflow.flashs').copy_remote_line()
        end,
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
    },
    opts = {
      search = {
        exclude = vim.cfg.misc__ft_exclude,
      },
      jump = {
        ----- affect t motion
        -- pos = 'start', -- jump to end of label, useful in insert mode jump.
        -- offset = 1, -- affect pos.
        autojump = true,
        nohlsearch = true,
      },
      modes = {
        -- options used when flash is activated through
        -- a regular search with `/` or `?`
        search = {
          enabled = false,
        },
        char = {
          multi_line = false,
          jump_labels = true,
        },
      },
      -- press ; to continue
      continue = true,
    },
    config = function(_, opts)
      require('flash').setup(opts)
    end,
  },
  {
    --- Readline keybindings,
    --- C-e, C-f, etc.
    'tpope/vim-rsi',
    vscode = true,
    event = {
      'InsertEnter',
      'CmdlineEnter',
    },
  },
})

plug({
  --- gaod -> (motion)aw(a word)
  'johmsalas/text-case.nvim',
  event = 'User FileOpenedAfter',
  opts = {
    default_keymappings_enabled = true,
    -- `prefix` is only considered if `default_keymappings_enabled` is true. It configures the prefix
    -- of the keymappings, e.g. `gau ` executes the `current_word` method with `to_upper_case`
    -- and `gaou` executes the `operator` method with `to_upper_case`.
    prefix = 'ga',
    -- By default, all methods are enabled. If you set this option with some methods omitted,
    -- these methods will not be registered in the default keymappings. The methods will still
    -- be accessible when calling the exact lua function e.g.:
    -- "<CMD>lua require('textcase').current_word('to_snake_case')<CR>"
    enabled_methods = {
      'to_upper_case',
      'to_lower_case',
      'to_snake_case',
      'to_dash_case',
      'to_title_dash_case',
      'to_constant_case',
      'to_dot_case',
      'to_phrase_case',
      'to_camel_case',
      'to_pascal_case',
      'to_title_case',
      'to_path_case',
      'to_upper_phrase_case',
      'to_lower_phrase_case',
    },
  },
})
