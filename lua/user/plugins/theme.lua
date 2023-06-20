local plug = require('libs.runtime.pack').plug

plug({
  {
    'rebelot/kanagawa.nvim',
    lazy = not vim.startswith(vim.cfg.ui__theme_name, 'kanagawa'),
    cond = vim.cfg.ui__theme_name == "kanagawa",
    opts = {
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = { bold = true },
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = { bold = true },
      variablebuiltinStyle = { italic = true },
      globalStatus = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      background = {
        -- dark = "wave",
        dark = 'dragon',
        light = "lotus",
      },
    },
    config = function(_, opts)
      require('kanagawa').setup(opts)
    end
  },

  ----- everforest
  {
    'sainnhe/everforest',
    lazy = vim.cfg.ui__theme_name ~= 'everforest',
    cond = vim.cfg.ui__theme_name == 'everforest',
    priority = 1000,
    init = function()
      vim.g.everforest_background = 'medium'
      vim.g.everforest_ui_contrast = 'high'
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_disable_italic_comment = false
      vim.g.everforest_transparent_background = false
      vim.g.everforest_dim_inactive_windows = false
      vim.g.everforest_sign_column_background = 'none'  -- "none" | "grey"
      vim.g.everforest_diagnostic_virtual_text = 'grey' -- "grey" | "colored"
      vim.g.everforest_diagnostic_text_highlight = 0
      vim.g.everforest_diagnostic_line_highlight = 0
    end
  }
})

plug({
  'mcchrish/zenbones.nvim',
  dependencies = {
    'rktjmp/lush.nvim'
  },
  lazy = not string.match(vim.cfg.ui__theme_name, 'bones'),
  priority = 1000,
  config = false,
  init = function()
    vim.g.forestbones = {
      -- solid_line_nr = true,
      darken_comments = 45,
      solid_float_border = true,
    }
  end,
})

plug({
  'Luxed/ayu-vim',
  lazy = not string.match(vim.cfg.ui__theme_name, 'ayu'),
  priority = 1000,
  config = false,
  init = function()
  end,
})
