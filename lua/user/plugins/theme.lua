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
  -- https://protesilaos.com/emacs/modus-themes-pictures
  'miikanissi/modus-themes.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  cond = vim.cfg.ui__theme_name == 'modus',
  opts = {
    -- `deuteranopia`,
    style = 'auto',
    --- @type 'deuteranopia' | 'tritanopia' | 'tinted' | 'default'
    variant = 'deuteranopia',
    dim_inactive = false,
    styles = {
      comments = { italic = false, bold = false },
      keywords = { italic = true },
      functions = { bold = false, italic = false },
    },
    on_highlights = function(hls, c)
      hls['@lsp.type.unresolvedReference'] = {
        undercurl = false,
        sp = c.error,
      }
      hls['LineNrAbove'] = {
        bg = 'none',
      }
      hls['LineNrBelow'] = {
        bg = 'none',
      }
      hls['FloatBorder'] = { link = 'NormalFloat' }
      hls['StatusLineNC'] = {
        bg = c.bg_active,
        fg = c.slate,
      }
      hls['MiniCursorword'] = {
        italic = true,
        bold = true,
        bg = 'NONE',
        fg = 'NONE',
      }
      hls['MiniCursorwordCurrent'] = {
        underline = false,
        bold = false,
        bg = 'NONE',
        fg = 'NONE',
      }
      hls['MiniIndentscopeSymbol'] = {
        fg = c.bg_dim,
        bg = 'NONE',
        bold = false,
      }

      hls.CocErrorSign = { link = 'DiagnosticError' }
      hls.CocWarningSign = { link = 'DiagnosticWarn' }
      hls.CocInfoSign = { link = 'DiagnosticInfo' }
      hls.CocHintSign = { link = 'DiagnosticHint' }
      hls.CocErrorFloat = { link = 'DiagnosticError' }
      hls.CocWarningFloat = { link = 'DiagnosticWarn' }
      hls.CocFloating = { link = 'NormalFloat' }
      hls.CocInfoFloat = { link = 'DiagnosticInfo' }
      hls.CocHintFloat = { link = 'DiagnosticHint' }
      hls.CocDiagnosticsError = { link = 'DiagnosticError' }
      hls.CocDiagnosticsWarning = { link = 'DiagnosticWarn' }
      hls.CocDiagnosticsInfo = { link = 'DiagnosticInfo' }
      hls.CocDiagnosticsHint = { link = 'DiagnosticHint' }
      hls.CocSelectedText = { fg = c.blue }
      hls.CocMenuSel = { link = 'PmenuSel' }
      hls.CocCodeLens = { fg = c.visual }
      hls.CocInlayHint = { fg = c.visual }
      hls.CocInlayHintType = { link = 'CocInlayHint' }
      hls.CocInlayHintParameter = { link = 'CocInlayHint' }
      hls.CocErrorHighlight = { undercurl = true, sp = c.red }
      hls.CocWarningHighlight = { sp = c.yellow, undercurl = true }
      hls.CocInfoHighlight = { sp = c.green, undercurl = true }
      hls.CocHintHighlight = { sp = c.orange, undercurl = true }

      return hls
    end,
  },
})

plug({
  'Mofiqul/dracula.nvim',
  event = 'User LazyTheme',
  name = 'dracula',
  priority = 1000,
  cond = vim.cfg.ui__theme_name == 'dracula',
  opts = {
    overrides = function(colors)
      return {
        WidgetTextHighlight = { fg = colors.cyan, bg = colors.black, bold = true },
        TabLineSel = { fg = colors.purple, bg = colors.bg, bold = true, italic = false },
        TabLine = { bg = colors.menu, fg = colors.white, italic = true },
        TabLineFill = { bg = colors.black, fg = colors.purple },
        StatusLineNC = { fg = colors.comment, bg = colors.menu },
        NormalA = { fg = colors.black, bg = colors.purple, bold = true },
        InsertA = { fg = colors.black, bg = colors.green, bold = true },
        VisualA = { fg = colors.black, bg = colors.blue, bold = true },
        CommandA = { fg = colors.black, bg = colors.red, bold = true },
        TermA = { fg = colors.black, bg = colors.yellow, bold = true },
        MotionA = { fg = colors.black, bg = colors.cyan, bold = true },
        TreesitterContext = { bg = colors.visual },
        TreesitterContextLineNumber = { link = 'TreesitterContext' },
      }
    end,
  },
})
