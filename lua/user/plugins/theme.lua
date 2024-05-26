local plug = require('userlib.runtime.pack').plug

plug({
  'gbprod/nord.nvim',
  event = vim.cfg.ui__theme_name:match('nord') and 'User LazyTheme' or nil,
  config = function()
    local utils = require('nord.utils')
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
        keywords = { italic = false },
        functions = { bold = true, italic = false },
        variables = {},
      },

      --- You can override specific highlights to use other groups or a hex color
      --- function will be called with all highlights and the colorScheme table
      on_highlights = function(hl, c)
        local float_bg = utils.blend(c.polar_night.bright, c.polar_night.origin, 0.5)
        hl.NormalFloat = { bg = float_bg }
        hl.FloatBorder = { bg = float_bg, fg = c.polar_night.light }
        -- hl.TelescopeNormal = { link = 'NormalFloat' }
        -- hl.TelescopeBorder = { link = 'FloatBorder' }

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
        hl.StatusLine = { fg = c.frost.ice, bg = c.polar_night.brighter }
        hl.StatusLineNC = { fg = c.polar_night.light, bg = c.polar_night.bright }
        hl.CocUnusedHighlight = { link = 'DiagnosticUnderlineWarn' }
        hl.CocInfoHighlight = { sp = c.aurora.green, undercurl = true }
        hl.CocHintHighlight = { sp = c.aurora.orange, undercurl = true }
        hl.TreesitterContextBottom = {
          underline = true,
          sp = c.polar_night.brightest,
        }
        hl.FzfLuaNormal = { link = 'NormalFloat' }
        hl.FzfLuaBorder = { link = 'FloatBorder' }
        hl.FzfLuaPreviewNormal = { link = 'Normal' }
      end,
    })
  end,
})

plug({
  'ellisonleao/gruvbox.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  cond = vim.cfg.ui__theme_name == 'gruvbox',
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
    contrast = 'soft', -- can be "hard", "soft" or empty string
    palette_overrides = {},
    overrides = {
      CocUnusedHighlight = { link = 'DiagnosticUnderlineWarn' },
      TelescopeSelection = { underline = true },
    },
    dim_inactive = false,
    transparent_mode = false,
  },
})

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
        MiniIndentscopeSymbol = { link = 'IndentBlanklineChar' },
        IndentLine = { link = 'IndentBlanklineChar' },
        IndentLineCurrent = { link = 'IndentBlanklineContextChar' },
        -- StatusLine = { bg = colors.theme.syn.fun, fg = colors.theme.ui.bg_m3 },
        -- StatusLineNC = { bg = colors.theme.ui.bg_m3, fg = colors.theme.ui.fg_dim },
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
        lotusWhite1 = '#E9E5D6',
        lotusWhite2 = '#F3EEDD',
        --- main bg
        lotusWhite3 = '#FDF6E3',
        --- tabline etc
        lotusWhite4 = '#f3eedd',
        lotusWhite5 = '#eee8d5',
      },
      theme = {
        all = {
          ui = {
            -- bg_gutter = 'none',
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
      dark = 'wave',
      -- dark = 'dragon',
      light = 'lotus',
    },
  },
})

plug({
  'rmehri01/onenord.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  cond = string.match(vim.cfg.ui__theme_name, 'onenord') ~= nil,
  opts = {
    borders = true,
    fade_nc = false,
    styles = {},
    inverse = {
      match_paren = false,
    },
    custom_highlights = {}, -- Overwrite default highlight groups
    custom_colors = {}, -- Overwrite default colors
  },
})
