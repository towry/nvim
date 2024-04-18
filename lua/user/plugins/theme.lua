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
    require('rose-pine').setup({
      styles = {
        transparency = false,
      },
      dark_variant = vim.o.background == 'light' and 'moon' or nil,
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
        StatusLine = { bg = 'iris', fg = 'base' },
        StatusLineNC = { bg = utils.blend(utils.parse_color('base'), utils.parse_color('iris'), 0.07), fg = 'base' },
        TabLineSel = { bg = utils.blend(utils.parse_color('overlay'), utils.parse_color('iris'), 0.1), fg = 'text' },
        TabLine = { bg = 'overlay', fg = 'text' },
        TelescopePrompt = { bg = 'base', fg = 'text' },
        TelescopePromptTitle = { bg = 'pine', fg = 'surface' },
        TelescopePreviewTitle = { bg = 'rose', fg = 'surface' },
        TelescopeMatching = { fg = 'gold' },
        TelescopeSelection = { fg = 'text', bg = 'muted' },
        NormalFloat = { bg = 'highlight_low' },
        FloatBorder = { bg = 'highlight_low' },
        TelescopeNormal = { link = 'NormalFloat' },
        TelescopeBorder = { link = 'FloatBorder' },
      },
    })
  end,
})
