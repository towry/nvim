local plug = require('userlib.runtime.pack').plug

plug({
  'rebelot/kanagawa.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  cond = string.match(vim.cfg.ui__theme_name, 'kanagawa') ~= nil,
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
        CybuFocus = { link = 'FlashCursor' },
        MiniIndentscopeSymbol = { link = 'IndentBlanklineChar' },
        IndentLine = { link = 'IndentBlanklineChar' },
        IndentLineCurrent = { link = 'IndentBlanklineContextChar' },
        StatusLine = { bg = colors.theme.syn.fun, fg = colors.theme.ui.bg_m3 },
        StatusLineNC = { bg = colors.theme.ui.whitespace, fg = colors.theme.ui.fg_dim },
        TelescopeNormal = { link = 'NormalFloat' },
        TelescopeBorder = { link = 'FloatBorder' },
        TelescopeSelection = { link = 'QuickFixLine' },
        FzfLuaNormal = { link = 'NormalFloat' },
        FzfLuaBorder = { link = 'FloatBorder' },
        FzfLuaPreviewNormal = { link = 'NormalFloat' },
        --- coc
        CocUnusedHighlight = { link = 'DiagnosticUnderlineHint' },
        -- flash
        FlashCursor = { fg = colors.theme.ui.fg, bg = colors.palette.waveBlue1 },
        WinSeparator = { fg = colors.palette.dragonPink, bg = 'NONE' },
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
        lotusWhite0 = '#ECE8D8',
        lotusWhite1 = '#F5DEAC',
        lotusWhite2 = '#F3EEDD',
        --- main bg
        lotusWhite3 = '#F6EED9',
        --- tabline etc
        lotusWhite4 = '#C5C0AF',
        lotusWhite5 = '#eee8d5',
      },
      theme = {
        all = {
          ui = {
            bg_gutter = 'none',
          },
        },
        lotus = {
          ui = {
            bg_p1 = '#DCD7BA',
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
      dark = 'dragon',
      light = 'lotus',
    },
  },
})

plug({
  'ellisonleao/gruvbox.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  enabled = vim.cfg.ui__theme_name == 'gruvbox',
  opts = {
    terminal_colors = true, -- add neovim terminal colors
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
      strings = true,
      emphasis = true,
      comments = true,
      operators = false,
      folds = true,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true, -- invert background for search, diffs, statuslines and errors
    contrast = '', -- can be "hard", "soft" or empty string
    palette_overrides = {},
    overrides = {},
    dim_inactive = false,
    transparent_mode = false,
  },
})
