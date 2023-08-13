local plug = require('userlib.runtime.pack').plug

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
    overrides = function(colors)
      return {
        --- mini files.
        MiniFilesTitleFocused = { fg = colors.palette.lotusWhite3, bg = colors.palette.waveRed, bold = true },
        MiniFilesBorderModified = {
          fg = colors.palette.samuraiRed,
        },
        --- window picker
        WindowPickerStatusLine = { bg = colors.theme.syn.fun, fg = colors.theme.ui.bg_m3 },
        WindowPickerStatusLineNC = { bg = colors.theme.syn.fun, fg = colors.theme.ui.bg_m3 },
      }
    end,
    colors = {
      palette = {
        crystalBlue = "#a7d8de",
        -- dragonBlack0 = "#191f24",
        -- dragonBlack1 = "#1c2228",
        -- dragonBlack2 = "#192024",
        -- dragonBlack3 = "#1c2428",
        -- dragonBlack4 = "#232c30",
        -- dragonBlack5 = "#2b353b",
        -- dragonBlack6 = "#3b464f",
        -- dragonBlue2 = "#7b96a3",
        -- winterBlue = "#223140",

        --- https://coolors.co/f5f4f2-f8f7f6-f9f9f8-fafafa-f1f5f1-dee2de-d4d8d4-caceca-a2a6a3-212121
        -- lotusWhite0 = "#e6eaed",
        -- lotusWhite1 = "#e4e6eb",
        -- lotusWhite2 = "##f0f2f5",
        -- lotusWhite3 = "#ffffff",
        -- lotusWhite4 = "#e6eaed",
        -- lotusWhite5 = "#f6f8fa",
      },
      theme = {
        all = {
          ui = {
            bg_gutter = "none",
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

plug({
  'mcchrish/zenbones.nvim',
  dependencies = {
    'rktjmp/lush.nvim'
  },
  lazy = not string.match(vim.cfg.ui__theme_name, 'bones'),
  priority = 1000,
  config = false,
  init = function()
    vim.g.neobones = {
      -- solid_line_nr = true,
      darken_comments = 45,
      solid_float_border = true,
    }
  end,
})

plug({
  'phha/zenburn.nvim',
  lazy = not string.match(vim.cfg.ui__theme_name, 'zenburn'),
  priority = 1000,
  opts = {
    theme = "zenburn",
  }
})
