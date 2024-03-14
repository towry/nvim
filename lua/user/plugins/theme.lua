local plug = require('userlib.runtime.pack').plug

plug({
  'gbprod/nord.nvim',
  version = false,
  event = 'User LazyTheme',
  priority = 1000,
  cond = vim.cfg.ui__theme_name == 'nord',
  config = function()
    require('nord').setup({
      borders = true,
      diff = { mode = 'fg' },
      errors = { mode = 'fg' },
      on_highlights = function(H, c)
        H['FloatBorder'] = {
          fg = c.polar_night.brighter,
          bg = c.none,
        }
        H['MiniCursorword'] = {
          italic = true,
          bold = true,
          bg = 'NONE',
          fg = 'NONE',
        }
        H['MiniCursorwordCurrent'] = {
          underline = false,
          bold = false,
          bg = 'NONE',
          fg = 'NONE',
        }
        H['MiniIndentscopeSymbol'] = {
          fg = c.polar_night.bright,
          bg = 'NONE',
          bold = false,
        }
        return H
      end,
    })
  end,
})

plug({
  -- 'ellisonleao/gruvbox.nvim',
  'pze/gruvbox.nvim',
  dev = false,
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
  -- https://protesilaos.com/emacs/modus-themes-pictures
  'miikanissi/modus-themes.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  enabled = vim.cfg.ui__theme_name == 'modus',
  opts = {
    -- `deuteranopia`,
    -- variant = 'tritanopia',
    -- variant = 'deuteranopia',
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
        bg = 'NONE',
        fg = c.fg_dim,
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
      hls['GitSignsChange'] = {
        fg = c.fg_changed,
        bg = 'NONE',
      }
      hls['GitSignsDelete'] = {
        fg = c.fg_removed,
        bg = 'NONE',
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
        fg = c.comment,
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
