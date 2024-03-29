local pack = require('userlib.runtime.pack')
local au = require('userlib.runtime.au')

---=================================
---Identation.
pack.plug({
  {
    'utilyre/sentiment.nvim',
    version = '*',
    event = 'User LazyUIEnterOncePost',
    enabled = false,
    cmd = {
      'NoMatchParen',
      'DoMatchParen',
    },
    opts = {
      excluded_filetypes = {},
      included_modes = { n = true, i = true },
      delay = 100,
    },
  },
  {
    'NMAC427/guess-indent.nvim',
    event = 'User LazyUIEnterOncePost',
    cmd = { 'GuessIndent' },
    opts = {
      auto_cmd = true, -- Set to false to disable automatic execution
      filetype_exclude = vim.cfg.misc__ft_exclude,
      override_editorconfig = false,
      buftype_exclude = vim.cfg.misc__buf_exclude,
    },
  },

  ---================================
  ---Indent guides.
  {
    'lukas-reineke/indent-blankline.nvim',
    event = au.user_autocmds.FileOpenedAfter_User,
    enabled = false,
    config = function()
      require('indent_blankline').setup({
        use_treesitter = true,
        show_current_context = false,
        buftype_exclude = {
          'nofile',
          'terminal',
        },
        filetype_exclude = {
          'help',
          'startify',
          'Outline',
          'alpha',
          'dashboard',
          'lazy',
          'neogitstatus',
          'NvimTree',
          'neo-tree',
          'Trouble',
        },
      })

      au.register_event(au.events.AfterColorschemeChanged, {
        name = 'update_indentline_hl',
        immediate = true,
        callback = function()
          -- local utils = require('userlib.runtime.utils')
          -- vim.api.nvim_set_hl(0, 'IndentBlanklineChar', utils.fg("FloatBorder"))
        end,
      })
    end,
  },

  ---==========================
  ---Indent scope.
  {
    'echasnovski/mini.indentscope',
    event = au.user_autocmds.FileOpenedAfter_User,
    enabled = true,
    config = function()
      require('mini.indentscope').setup({
        symbol = '│',
        options = {
          try_as_border = true,
        },
      })
    end,
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = vim.cfg.misc__ft_exclude,
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
})
