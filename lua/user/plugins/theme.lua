local plug = require('userlib.runtime.pack').plug

plug({
  'towry/flexoki-neovim',
  dev = false,
  branch = 'next',
  cond = vim.cfg.ui__theme_name == 'flexoki',
  name = 'flexoki',
  event = 'User LazyTheme',
  config = function()
    local palette = require('flexoki.palette')
    local c = palette.palette()

    local hl = {}
    hl.CocMenuSel = { link = 'PmenuSel' }
    hl.WinbarPathTail = {
      fg = c['ora'],
    }
    hl.WinBar = {
      fg = c['ui_3'],
      bg = 'none',
    }
    hl.WinBarNC = {
      fg = c['ui_3'],
      bg = 'none',
    }

    require('flexoki').setup({
      ---Set the desired variant: 'auto' will follow the vim background,
      ---defaulting to 'main' for dark and 'dawn' for light. To change the dark
      ---variant, use `options.dark_variant = 'moon'`.
      variant = 'auto',
      dark_variant = 'dark',
      ---Set the desired light variant: applies when `options.variant` is set to
      ---'auto' to match `vim.o.background`
      light_variant = 'light',
      styles = {
        undercurl = true,
      },

      highlight_groups = hl,
    })
  end,
})

plug({
  'rose-pine/neovim',
  name = 'rose-pine',
  priority = 1000,
  lazy = false,
  enabled = vim.cfg.ui__theme_name == 'rose-pine',
  --- https://github.com/rose-pine/neovim?tab=readme-ov-file#options
  config = function()
    local utils = require('rose-pine.utilities')
    local blend = function(fg, bg, precise)
      return utils.blend(utils.parse_color(fg), utils.parse_color(bg), precise)
    end
    require('rose-pine').setup({
      styles = {
        transparency = false,
      },
      -- dark_variant = 'moon',
      highlight_groups = {
        CocErrorSign = { link = 'DiagnosticError' },
        CocWarningSign = { link = 'DiagnosticWarn' },
        CocInfoSign = { link = 'DiagnosticInfo' },
        CocHintSign = { link = 'DiagnosticHint' },
        CocErrorFloat = { link = 'DiagnosticError' },
        CocWarningFloat = { link = 'DiagnosticWarn' },
        CocFloating = { link = 'NormalFloat' },
        CocInfoFloat = { link = 'DiagnosticInfo' },
        CocHintFloat = { link = 'DiagnosticHint' },
        CocDiagnosticsError = { link = 'DiagnosticError' },
        CocDiagnosticsWarning = { link = 'DiagnosticWarn' },
        CocDiagnosticsInfo = { link = 'DiagnosticInfo' },
        CocDiagnosticsHint = { link = 'DiagnosticHint' },
        CocUnusedHighlight = { link = 'DiagnosticUnderlineWarn' },
        -- +--
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
        FzfLuaColorsBgSel = { fg = 'rose' },
        FzfLuaTitle = { bg = 'foam', fg = 'base', bold = false },
        StatusLine = { bg = 'foam', fg = 'base' },
        StatusLineNC = {
          bg = utils.blend(utils.parse_color('base'), utils.parse_color('foam'), 0.07),
          fg = 'base',
        },
        TabLineSel = { bg = utils.blend(utils.parse_color('overlay'), utils.parse_color('foam'), 0.1), fg = 'text' },
        TabLine = { bg = 'overlay', fg = 'text' },
        TelescopePrompt = { bg = 'base', fg = 'text' },
        TelescopePromptTitle = { bg = 'pine', fg = 'surface' },
        TelescopePreviewTitle = { bg = 'rose', fg = 'surface' },
        TelescopeMatching = { fg = 'gold' },
        TelescopeSelection = { fg = 'text', bg = 'highlight_high' },
        TelescopeNormal = { link = 'NormalFloat' },
        TelescopeBorder = { link = 'FloatBorder' },
        NormalFloat = { bg = 'highlight_low' },
        FloatBorder = { bg = 'highlight_low' },
      },
    })
  end,
})

plug({
  'gbprod/nord.nvim',
  event = 'User LazyTheme',
  cond = vim.cfg.ui__theme_name:match('nord'),
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
