local plug = require('userlib.runtime.pack').plug

plug({
  'binhtran432k/dracula.nvim',
  event = 'User LazyTheme',
  config = function()
    require('dracula').setup({
      style = 'default',
      light_style = 'day',
      dim_inactive = false,
      on_highlights = function(hl, c)
        local util = require("dracula.util")
        local function make_alpha(color, alpha)
          return util.blend(color, c.bg, alpha)
        end
        hl.WinSeparator = {
          fg = c.selection,
          bold = true,
        }
        hl.MiniIndentscopeSymbol = {
          fg = c.selection,
        }
        hl.CocErrorSign = { link = "DiagnosticError" }
        hl.CocWarningSign = { link = "DiagnosticWarn" }
        hl.CocInfoSign = { link = "DiagnosticInfo" }
        hl.CocHintSign = { link = "DiagnosticHint" }
        hl.CocErrorFloat = { link = "DiagnosticError" }
        hl.CocWarningFloat = { link = "DiagnosticWarn" }
        hl.CocFloating = { link = "NormalFloat" }
        hl.CocInfoFloat = { link = "DiagnosticInfo" }
        hl.CocHintFloat = { link = "DiagnosticHint" }
        hl.CocDiagnosticsError = { link = "DiagnosticError" }
        hl.CocDiagnosticsWarning = { link = "DiagnosticWarn" }
        hl.CocDiagnosticsInfo = { link = "DiagnosticInfo" }
        hl.CocDiagnosticsHint = { link = "DiagnosticHint" }
        hl.CocSelectedText = { fg = c.visual }
        hl.CocMenuSel = { link = "PmenuSel" }
        hl.CocCodeLens = { fg = c.visual }
        hl.CocInlayHint = { fg = make_alpha(c.comment, 0.3) }
        hl.CocInlayHintType = { link = 'CocInlayHint' }
        hl.CocInlayHintParameter = { link = 'CocInlayHint' }
        hl.CocErrorHighlight = { undercurl = true, sp = c.error }
        hl.CocWarningHighlight = { sp = c.warn, undercurl = true, }
        hl.CocInfoHighlight = { sp = c.info, undercurl = true, }
        hl.CocHintHighlight = { sp = c.hint, undercurl = true, }
      end,
    })
  end,
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
      transparent = false,        -- Enable this to disable setting the background color
      terminal_colors = true,     -- Configure the colors used when opening a `:terminal` in Neovim
      diff = { mode = 'fg' },     -- enables/disables colorful backgrounds when used in diff mode. values : [bg|fg]
      borders = true,             -- Enable the border between verticaly split windows visible
      errors = { mode = 'fg' },   -- Display mode for errors and diagnostics
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
        hl.CocErrorSign = { link = "DiagnosticError" }
        hl.CocWarningSign = { link = "DiagnosticWarn" }
        hl.CocInfoSign = { link = "DiagnosticInfo" }
        hl.CocHintSign = { link = "DiagnosticHint" }
        hl.CocErrorFloat = { link = "DiagnosticError" }
        hl.CocWarningFloat = { link = "DiagnosticWarn" }
        hl.CocFloating = { link = "NormalFloat" }
        hl.CocInfoFloat = { link = "DiagnosticInfo" }
        hl.CocHintFloat = { link = "DiagnosticHint" }
        hl.CocDiagnosticsError = { link = "DiagnosticError" }
        hl.CocDiagnosticsWarning = { link = "DiagnosticWarn" }
        hl.CocDiagnosticsInfo = { link = "DiagnosticInfo" }
        hl.CocDiagnosticsHint = { link = "DiagnosticHint" }
        hl.CocSelectedText = { fg = c.snow_storm.origin }
        hl.CocMenuSel = { link = "PmenuSel" }
        hl.CocCodeLens = { fg = c.polar_night.bright }
        hl.CocInlayHint = { fg = c.polar_night.bright }
        hl.CocInlayHintType = { link = 'CocInlayHint' }
        hl.CocInlayHintParameter = { link = 'CocInlayHint' }
        hl.CocErrorHighlight = { undercurl = true, sp = c.aurora.red }
        hl.CocWarningHighlight = { sp = c.aurora.yellow, undercurl = true, }
        hl.CocInfoHighlight = { sp = c.aurora.green, undercurl = true, }
        hl.CocHintHighlight = { sp = c.aurora.orange, undercurl = true, }
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
        fg = c.fg_dim,
      }
      hls['WinSeparator'] = {
        fg = c.bg_dim,
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

      return hls
    end,
  },
})

plug({
  'rebelot/kanagawa.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  cond = string.match(vim.cfg.ui__theme_name, 'kanagawa') ~= nil,
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
