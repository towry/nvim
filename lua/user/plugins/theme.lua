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
  'EdenEast/nightfox.nvim',
  event = 'User LazyTheme',
  priority = 1000,
  enabled = string.match(vim.cfg.ui__theme_name, 'fox') ~= nil,
  config = function()
    local pal = require('nightfox.palette').load('nordfox')
    -- https://github.com/EdenEast/nightfox.nvim?tab=readme-ov-file#configuration
    require('nightfox').setup({
      options = {
        styles = {
          comments = 'italic',
          keywords = 'bold',
          types = 'italic,bold',
        },
      },
      palettes = {
        all = {},
      },
      specs = {},
      groups = {
        all = {
          NormalFloat = { link = 'Pmenu' },
          FloatBorder = { link = 'Pmenu' },
          TelescopeNormal = { link = 'NormalFloat' },
          TelescopeBorder = { link = 'FloatBorder' },
          TelescopeSelection = { link = 'PmenuSel' },
        },
      },
    })
  end,
  init = function()
    vim.g.nightfox_day = 'nordfox'
    vim.g.nightfox_night = 'nordfox'
  end,
})
