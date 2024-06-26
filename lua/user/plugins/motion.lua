local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')

plug({
  'chrisgrieser/nvim-various-textobjs',
  enabled = false,
  event = 'BufReadPost',
  opts = {
    useDefaultKeymaps = true,
    disabledKeymaps = {
      'gc',
    },
  },
})

plug({
  'echasnovski/mini.surround',
  version = '*',
  event = au.user_autocmds.FileOpened_User,
  keys = {
    { 'z]', desc = 'Mini surround find right' },
    { 'z[', desc = 'Mini surround find left' },
  },
  opts = {
    mappings = {
      add = 'ys',
      delete = 'ds',
      find = 'z]',
      find_left = 'z[',
      highlight = '',
      replace = 'cs',
      update_n_lines = '',

      -- Add this only if you don't want to use extended mappings
      suffix_last = '',
      suffix_next = '',
    },
    search_method = 'cover_or_next',
  },
})

plug({
  {
    'kylechui/nvim-surround',
    vscode = 'true',
    version = '*',
    enabled = false,
    event = au.user_autocmds.FileOpened_User,
    opts = {
      keymaps = {
        delete = 'ds',
      },
    },
  },

  {
    -- https://github.com/Wansmer/treesj
    'Wansmer/treesj',
    vscode = true,
    keys = {
      {
        'JJ',
        '<cmd>lua require("treesj").toggle()<cr>',
        desc = 'Toggle',
      },
      {
        'Js',
        '<cmd>lua require("treesj").split()<cr>',
        desc = 'Split',
      },
      {
        'Jj',
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
        mode = { 'n' },
        function()
          require('flash').jump({
            search = {
              multi_window = false,
            },
          })
        end,
        nowait = true,
        desc = 'Flash',
      },
      {
        '[s',
        mode = { 'n' },
        function()
          require('flash').jump({
            search = {
              wrap = false,
              forward = false,
              multi_window = false,
            },
          })
        end,
        desc = 'Flash up',
      },
      {
        ']s',
        mode = { 'n' },
        function()
          require('flash').jump({
            search = {
              wrap = false,
              multi_window = false,
            },
          })
        end,
        desc = 'Flash down',
      },
      {
        -- dont use s, cause it used in another motion plugin
        --- cs not working because surround use it.
        --- cm, dm
        'v',
        mode = { 'o', 'x' },
        function()
          require('flash').jump({
            search = { wrap = false, multi_window = false },
            label = {
              uppercase = false,
            },
          })
        end,
        desc = 'Flash in motion',
      },
      {
        'V',
        mode = { 'o', 'x' },
        function()
          require('flash').jump({
            search = { forward = false, wrap = false, multi_window = false },
            label = {
              uppercase = false,
            },
          })
        end,
        desc = 'Flash in motion',
      },
      {
        '<C-s><C-s>',
        mode = { 'n', 'x' },
        nowait = true,
        function()
          require('userlib.workflow.flashs').jump_to_line()
        end,
        desc = 'Flash jump to line',
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
        mode = { 'o', 'x' },
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
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
      continue = false,
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

plug({
  'chrisgrieser/nvim-spider',
  lazy = true,
  vscode = true,
  init = au.schedule_lazy(function()
    local set = vim.keymap.set
    local del = vim.keymap.del
    local motion_w_rhs = [[<cmd>lua require('spider').motion('w')<CR>]]
    local motion_b_rhs = [[<cmd>lua require('spider').motion('b')<CR>]]
    local motion_e_rhs = [[<cmd>lua require('spider').motion('e')<CR>]]
    local mods = { 'n', 'o', 'x' }

    local setup_keys = function()
      set(mods, 'w', motion_w_rhs, {})
      set(mods, 'b', motion_b_rhs, {})
      set(mods, 'e', motion_e_rhs, {})
    end
    local remove_keys = function()
      del(mods, 'w')
      del(mods, 'b')
      del(mods, 'e')
    end

    local spider_on = false
    if spider_on then
      setup_keys()
    end

    vim.api.nvim_create_user_command('ToggleSpider', function()
      if spider_on then
        spider_on = false
        remove_keys()
        vim.notify('Spider motion off')
      else
        spider_on = true
        vim.notify('Spider motion on')
        setup_keys()
      end
    end, {})
  end),
})

plug({
  'rainbowhxch/accelerated-jk.nvim',
  enabled = false,
  event = 'VeryLazy',
  opts = {
    acceleration_limit = 90,
  },
  init = function()
    vim.api.nvim_set_keymap('n', 'j', '<Plug>(accelerated_jk_gj)', { noremap = true, nowait = true })
    vim.api.nvim_set_keymap('n', 'k', '<Plug>(accelerated_jk_gk)', { noremap = true, nowait = true })
  end,
})
