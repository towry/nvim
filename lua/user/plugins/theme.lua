local plug = require('userlib.runtime.pack').plug

plug({
  'daschw/leaf.nvim',
  event = 'User LazyTheme',
  dev = false,
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'leaf'),
  enabled = vim.cfg.ui__theme_name == 'leaf',
  opts = {
    overrides = {
      NonText = {
        link = 'Comment',
      },
      MiniCursorword = {
        style = "italic",
      },
      MiniCursorwordCurrent = {
        style = "bold"
      }
    }
  },
})

plug({
  -- https://protesilaos.com/emacs/modus-themes-pictures
  'miikanissi/modus-themes.nvim',
  event = 'User LazyTheme',
  dev = false,
  priority = 1000,
  lazy = not string.match(vim.cfg.ui__theme_name, 'modus'),
  enabled = vim.cfg.ui__theme_name == 'modus',
  opts = {
    variant = 'tritanopia',
    -- variant = 'tinted'
  }
})

plug({
  'rebelot/kanagawa.nvim',
  event = 'User LazyTheme',
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
        dragonBlack0 = "#191f24",
        dragonBlack1 = "#1c2228",
        dragonBlack2 = "#192024",
        dragonBlack3 = "#1c2428",
        dragonBlack4 = "#232c30",
        dragonBlack5 = "#2b353b",
        dragonBlack6 = "#3b464f",
        dragonBlue2 = "#7b96a3",
        winterBlue = "#223140",
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
      dark = "wave",
      -- dark = 'dragon',
      light = "lotus",
    },
  },
})
