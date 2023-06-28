local plug = require('libs.runtime.pack').plug

plug({
  {
    'rebelot/kanagawa.nvim',
    event = 'User LazyTheme',
    enabled = vim.cfg.ui__theme_name == "kanagawa",
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
    event = 'User LazyTheme',
    enabled = vim.cfg.ui__theme_name == 'everforest',
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
  event = 'User LazyTheme',
  enabled = string.match(vim.cfg.ui__theme_name, 'bones') ~= nil,
  config = false,
  init = function()
    vim.g.neobones = {
      solid_float_border = true,
      colorize_diagnostic_underline_text = true,
      transparent_background = false,
      -- light
      -- darken_comments = 30,
      lightness = 'dim',
      darken_cursor_line = 10,
      --- dark
      lighten_cursor_line = 15,
      -- lighten_comments = 30,
      lighten_non_text = 22,
      darkness = 'warm',
    }
    vim.g.forestbones = {
      -- solid_line_nr = true,
      darken_comments = 45,
      solid_float_border = true,
    }

    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = 'forestbones',
      group = vim.api.nvim_create_augroup('_custom_forestbones_', { clear = true }),
      callback = function()
        local lush = require "lush"
        local base = require "zenbones"

        -- Create some specs
        local specs = lush.parse(function()
          return {
            -- darken cursorline
            -- CursorLine { base.CursorLine, bg = '#374145' },
          }
        end)
        -- Apply specs using lush tool-chain
        lush.apply(lush.compile(specs))
      end
    })
  end,
})


plug({
  'Luxed/ayu-vim',
  event = 'User LazyTheme',
  lazy = false,
  enabled = string.match(vim.cfg.ui__theme_name, 'ayu') ~= nil,
  config = false,
})
