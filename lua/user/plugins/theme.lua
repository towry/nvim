local plug = require('userlib.runtime.pack').plug

plug({
  -- 'kepano/flexoki-neovim',
  'towry/flexoki-neovim',
  dev = true,
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
  'towry/dracula-mini.nvim',
  event = 'User LazyTheme',
  cond = vim.cfg.ui__theme_name:match('dracula-mini'),
  dev = true,
  config = function()
    require('dracula-mini').setup({
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
        hl.WinbarPathTail = {
          fg = c.aurora.green,
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
