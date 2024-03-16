local plug = require('userlib.runtime.pack').plug

plug({
  'pze/nord.nvim',
  event = 'User LazyTheme',
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
        comments = { italic = true },
        keywords = {},
        functions = {},
        variables = {},
      },

      --- You can override specific highlights to use other groups or a hex color
      --- function will be called with all highlights and the colorScheme table
      on_highlights = function(highlights, colors) end,
    })
  end,
})

plug({
  -- https://protesilaos.com/emacs/modus-themes-pictures
  'miikanissi/modus-themes.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  -- cond = vim.cfg.ui__theme_name == 'modus',
  opts = {
    -- `deuteranopia`,
    -- variant = 'tritanopia',
    variant = 'tinted',
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
