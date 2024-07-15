return {
  'towry/internal',
  opts = {
    colorscheme = 'nightfox',
  },
  dependencies = { {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    event = "VeryLazy",
    opts = {
      compile = true,
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = { bold = true },
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = { bold = true },
      variablebuiltinStyle = { italic = true },
      globalStatus = true,
      overrides = function(colors) -- add/modify highlights
        -- do not foget to run ':KanagawaCompile'
        return {
          -- flash
          FlashCursor = { fg = colors.theme.ui.fg, bg = colors.palette.waveBlue1 },
          WinSeparator = { fg = colors.palette.dragonPink, bg = "NONE" },
        }
      end,
      colors = {
        palette = {
          -- + green
          -- lotusWhite0 = '#B9C8B7',
          -- lotusWhite1 = '#C2CDBE',
          -- lotusWhite2 = '#CAD2C5',
          -- lotusWhite3 = '#E9EDE6',
          -- lotusWhite4 = '#F3F5F1',
          -- lotusWhite5 = '#ffffff',

          --- + solarized
          lotusWhite0 = "#ECE8D8",
          lotusWhite1 = "#F5DEAC",
          lotusWhite2 = "#F3EEDD",
          --- main bg
          lotusWhite3 = "#F6EED9",
          --- tabline etc
          lotusWhite4 = "#C5C0AF",
          lotusWhite5 = "#eee8d5",
        },
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
          lotus = {
            ui = {
              bg_p1 = "#DCD7BA",
              -- bg_m3 = '#586e75',
            },
          },
          dragon = {
            ui = {},
          },
        },
      },
      background = {
        -- dark = 'wave',
        dark = "dragon",
        light = "lotus",
      },
    },
  },

    {
      "EdenEast/nightfox.nvim",
      priority = 1000,
      event = "VeryLazy",
      opts = {
        options = {
          transparent = false,
          styles = {
            keywords = "italic",
            types = "italic,bold",
          },
        },
        groups = {
          all = {
            WidgetTextHighlight = {
              fg = "palette.blue",
              bg = "palette.bg0",
            },
            FloatBorder = { link = "NormalFloat" },
            FzfLuaNormal = { link = "NormalFloat" },
            FzfLuaBorder = { link = "FloatBorder" },
          },
          -- https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md#palette
          nordfox = {},
        },
      },
    },
  }
}
