return {
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
}
