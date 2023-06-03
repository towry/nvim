local au = require('user.runtime.au');

return {
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', },
    opts = {
      PATH = 'prepend',
      ui = {
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = vim.cfg.ui__float_border,
      },
    }
  },

  {
    'neovim/nvim-lspconfig',
    name = 'lsp',
    event = au.user_autocmds.FileOpened,
    dependencies = {
      'jose-elias-alvarez/typescript.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'jose-elias-alvarez/null-ls.nvim',
      'williamboman/mason-lspconfig.nvim',
      'j-hui/fidget.nvim',
    },
    config = function()
      require_plugin_spec('lsp.setup').config()
    end,
  },

  {
    'lukas-reineke/lsp-format.nvim',
    opts = {
      sync = false,
    },
  },

  {
    'nvimdev/lspsaga.nvim',
    cmd = { 'Lspsaga', },
    dependencies = {
      --Please make sure you install markdown and markdown_inline parser
      { 'nvim-treesitter/nvim-treesitter' },
    },
    opts = {
      request_timeout = 1500,
      code_action = {
        num_shortcut = true,
        show_server_name = true,
        extend_gitsigns = true,
        keys = {
          -- string | table type
          quit = '<ESC>',
          exec = '<CR>',
        },
      },
      lightbulb = {
        enable = false,
        enable_in_insert = false,
        sign = true,
        sign_priority = 40,
        virtual_text = true,
      },
      diagnostic = {
        on_insert = false,
        on_insert_follow = false,
        show_virt_line = false,
        border_follow = true,
        text_hl_follow = true,
        show_code_action = false,
        keys = {
          quit = '<ESC>',
        },
      },
      callhierarchy = {
        keys = {
          quit = '<ESC>',
          vsplit = 'v',
          split = 'x',
        },
      },
      symbol_in_winbar = {
        enable = false,
      },
      beacon = {
        enable = false,
      },
      ui = {
        border = vim.cfg.ui__float_border, -- single, double, rounded, solid, shadow.
        winblend = 1,
      },
    }
  },

  {
    'folke/neodev.nvim',
  },

  {
    'lvimuser/lsp-inlayhints.nvim',
    branch = "anticonceal",
    event = 'LspAttach',
    config = true,
  },

  {
    'simrat39/rust-tools.nvim',
    ft = { 'rust', 'toml' },
    config = function()
      require_plugin_spec('lsp.rust.rc').config()
    end,
  }
}
