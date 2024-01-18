local plug = require('userlib.runtime.pack').plug

plug({
  'sainnhe/everforest',
  event = 'User LazyTheme',
  priority = 1000,
  enabled = vim.cfg.ui__theme_name == 'everforest',
  init = function()
    vim.g.everforest_background = 'medium'
    vim.g.everforest_ui_contrast = 'high'
    vim.g.everforest_better_performance = 0
    vim.g.everforest_enable_italic = 1
    vim.g.everforest_disable_italic_comment = false
    vim.g.everforest_transparent_background = false
    vim.g.everforest_dim_inactive_windows = false
    vim.g.everforest_sign_column_background = 'none' -- "none" | "grey"
    vim.g.everforest_diagnostic_virtual_text = 'grey' -- "grey" | "colored"
    vim.g.everforest_diagnostic_text_highlight = 1
    vim.g.everforest_diagnostic_line_highlight = 1
    vim.g.everforest_current_word = 'underline'
  end,
})

plug({
  'rose-pine/neovim',
  name = 'rose-pine',
  event = 'User LazyTheme',
  priority = 1000,
  enabled = vim.cfg.ui__theme_name == 'rose-pine',
  --- https://github.com/rose-pine/neovim?tab=readme-ov-file#options
  config = function()
    require('rose-pine').setup({
      -- dark_variant = 'moon',
      highlight_groups = {
        Pmenu = {
          fg = 'subtle',
          bg = 'overlay',
        },
        PmenuExtra = {
          link = 'Pmenu',
        },
        PmenuSel = {
          bg = 'gold',
        },
        StatusLine = { fg = 'love', bg = 'love', blend = 10 },
        StatusLineNC = { fg = 'subtle', bg = 'surface' },
        MiniCursorword = {
          italic = true,
          bold = true,
          bg = 'NONE',
          fg = 'text',
        },
        MiniCursorwordCurrent = {
          underline = false,
          bold = true,
          bg = 'NONE',
          fg = 'NONE',
        },
        FzfLuaNormal = { link = 'Normal' },
        FzfLuaBorder = { link = 'LineNr' },
        FzfLuaPreviewNormal = { link = 'Normal' },
      },
    })
  end,
})

plug({
  'daschw/leaf.nvim',
  event = 'User LazyTheme',
  enabled = vim.cfg.ui__theme_name == 'leaf',
  opts = {
    overrides = {
      NonText = {
        link = 'Comment',
      },
      MiniCursorword = {
        style = 'italic',
      },
      MiniCursorwordCurrent = {
        style = 'bold',
      },
    },
  },
})

plug({
  -- https://protesilaos.com/emacs/modus-themes-pictures
  'miikanissi/modus-themes.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  enabled = vim.cfg.ui__theme_name == 'modus',
  opts = {
    variant = 'tritanopia',
    -- variant = 'tinted'
    on_highlights = function(highlights, colors)
      local is_dark = vim.o.background == 'dark'
      highlights['FlashLabel'] = {
        fg = colors.bg_main_dim,
        bg = colors.bg_yellow_intense,
        bold = true,
      }
      highlights['FlashBackdrop'] = {
        fg = is_dark and colors.fg_dim or '#9f9f9f',
      }
    end,
  },
})

plug({
  'rebelot/kanagawa.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  enabled = string.match(vim.cfg.ui__theme_name, 'kanagawa') ~= nil,
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
      palette = {
        dragonBlack0 = '#191f24',
        dragonBlack1 = '#1c2228',
        dragonBlack2 = '#192024',
        dragonBlack3 = '#1c2428',
        dragonBlack4 = '#232c30',
        dragonBlack5 = '#2b353b',
        dragonBlack6 = '#3b464f',
        dragonBlue2 = '#7b96a3',
        winterBlue = '#223140',
      },
      theme = {
        all = {
          ui = {
            -- bg_gutter = "none",
          },
        },
      },
    },
    background = {
      dark = 'wave',
      -- dark = 'dragon',
      light = 'lotus',
    },
  },
})
