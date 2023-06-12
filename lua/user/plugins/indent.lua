local pack = require('libs.runtime.pack')

---=================================
---Identation.
pack.plug({
  {
    'NMAC427/guess-indent.nvim',
    event = 'InsertEnter',
    cmd = { 'GuessIndent' },
    opts = {
      auto_cmd = true, -- Set to false to disable automatic execution
      filetype_exclude = vim.cfg.misc__ft_exclude,
      buftype_exclude = vim.cfg.misc__buf_exclude,
    }
  },

  ---================================
  ---Indent guides.
  {
    'lukas-reineke/indent-blankline.nvim',
    event = au.user_autocmds.FileOpened_User,
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
        name = "update_indentline_hl",
        immediate = true,
        callback = function()
          -- local utils = require('libs.runtime.utils')
          -- vim.api.nvim_set_hl(0, 'IndentBlanklineChar', utils.fg("FloatBorder"))
        end,
      })
    end,
  },

  ---==========================
  ---Indent scope.
  {
    'echasnovski/mini.indentscope',
    event = {
      'BufRead', 'BufNewFile',
    },
    config = function()
      require('mini.indentscope').setup({
        symbol = '│',
        options = {
          try_as_border = true,
        },
      })
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  }
})
