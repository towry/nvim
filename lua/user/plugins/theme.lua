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

plug({
  -- 'pze/nord.nvim',
  'gbprod/nord.nvim',
  event = 'User LazyTheme',
  cond = vim.cfg.ui__theme_name:match('nord'),
  dev = false,
  config = function()
    require('nord').setup({
      -- your configuration comes here
      -- or leave it empty to use the default settings
      transparent = false, -- Enable this to disable setting the background color
      terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
      diff = { mode = 'fg' }, -- enables/disables colorful backgrounds when used in diff mode. values : [bg|fg]
      borders = true, -- Enable the border between verticaly split windows visible
      errors = { mode = 'fg' }, -- Display mode for errors and diagnostics
      -- values : [bg|fg|none]
      search = { theme = 'vim' }, -- theme for highlighting search results
      -- values : [vim|vscode]
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = false, bold = false },
        keywords = { italic = true },
        functions = { bold = true, italic = true },
        variables = {},
      },

      --- You can override specific highlights to use other groups or a hex color
      --- function will be called with all highlights and the colorScheme table
      on_highlights = function(hl, c)
        hl.CocErrorSign = { link = 'DiagnosticError' }
        hl.CocWarningSign = { link = 'DiagnosticWarn' }
        hl.CocInfoSign = { link = 'DiagnosticInfo' }
        hl.CocHintSign = { link = 'DiagnosticHint' }
        hl.CocErrorFloat = { link = 'DiagnosticError' }
        hl.CocWarningFloat = { link = 'DiagnosticWarn' }
        hl.CocFloating = { link = 'NormalFloat' }
        hl.CocInfoFloat = { link = 'DiagnosticInfo' }
        hl.CocHintFloat = { link = 'DiagnosticHint' }
        hl.CocDiagnosticsError = { link = 'DiagnosticError' }
        hl.CocDiagnosticsWarning = { link = 'DiagnosticWarn' }
        hl.CocDiagnosticsInfo = { link = 'DiagnosticInfo' }
        hl.CocDiagnosticsHint = { link = 'DiagnosticHint' }
        hl.CocSelectedText = { fg = c.snow_storm.origin }
        hl.CocMenuSel = { link = 'PmenuSel' }
        hl.CocCodeLens = { fg = c.polar_night.bright }
        hl.CocInlayHint = { fg = c.polar_night.bright }
        hl.CocInlayHintType = { link = 'CocInlayHint' }
        hl.CocInlayHintParameter = { link = 'CocInlayHint' }
        hl.CocErrorHighlight = { undercurl = true, sp = c.aurora.red }
        hl.CocWarningHighlight = { sp = c.aurora.yellow, undercurl = true }
        hl.CocInfoHighlight = { sp = c.aurora.green, undercurl = true }
        hl.CocHintHighlight = { sp = c.aurora.orange, undercurl = true }
        hl.TreesitterContextBottom = {
          underline = true,
          sp = c.polar_night.brightest,
        }
      end,
    })
  end,
})

plug({
  -- https://protesilaos.com/emacs/modus-themes-pictures
  'miikanissi/modus-themes.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  cond = vim.cfg.ui__theme_name == 'modus',
  opts = {
    -- `deuteranopia`,
    -- variant = 'tritanopia',
    variant = 'tritanopia',
    dim_inactive = false,
    styles = {
      comments = { italic = false, bold = false },
      keywords = { italic = true },
      functions = { bold = true, italic = true },
    },
    on_highlights = function(hls, c)
      local is_dark = vim.o.background == 'dark'
      hls['FlashLabel'] = {
        fg = c.bg_main_dim,
        bg = c.bg_yellow_intense,
        bold = true,
      }
      hls['FlashBackdrop'] = {
        fg = is_dark and c.fg_dim or '#9f9f9f',
      }
      hls['LineNr'] = {
        fg = c.bg_active,
      }
      hls['WinSeparator'] = {
        fg = c.bg_active,
      }
      hls['Winbar'] = {
        fg = c.fg_active,
        bg = c.bg_main,
      }
      hls['WinbarNc'] = {
        fg = c.fg_inactive,
        bg = c.bg_main,
      }
      hls['CursorLineNr'] = {
        bg = 'NONE',
        fg = c.fg_main,
        bold = true,
      }
      hls['FzfLuaNormal'] = { link = 'Normal' }
      hls['FzfLuaBorder'] = { link = 'LineNr' }
      hls['FzfLuaPreviewNormal'] = { link = 'Normal' }
      hls['FoldColumn'] = { bg = c.bg_main, fg = c.fg_dim, bold = false }
      hls['GitSignsAdd'] = {
        fg = c.fg_added,
        bg = 'NONE',
      }
      hls['GitSignsAddNr'] = {
        fg = c.fg_added,
        bg = 'NONE',
      }
      hls['GitSignsChange'] = {
        fg = c.fg_changed,
        bg = 'NONE',
      }
      hls['GitSignsChangeNr'] = {
        fg = c.fg_changed,
        bg = 'NONE',
      }
      hls['GitSignsDelete'] = {
        fg = c.fg_removed,
        bg = 'NONE',
      }
      hls['GitSignsDeleteNr'] = {
        fg = c.fg_removed,
        bg = 'NONE',
      }
      hls['StatusLine'] = {
        bg = c.bg_active,
        fg = c.bg_alt,
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
