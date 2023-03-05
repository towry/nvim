local M = {}

M.setup_marks = function()
  require('marks').setup({
    default_mappings = false,
    builtin_marks = {},
    refresh_interval = 600,
    excluded_filetypes = { 'oil', 'expJABS', 'NvimTree' },
    -- keymaps for marks.
    mappings = {
      preview = 'm:',
      toggle = 'm<space>',
      next = 'm,',
      prev = 'm.',
      delete_buf = 'm<bs>',
    },
  })

  local colors = require('ty.contrib.ui').colors()
  vim.api.nvim_set_hl(0, 'MarkSignHL', {
    bg = colors.marks_sign,
    fg = '#ffffff',
    bold = true,
    italic = true,
  })
end

M.setup_portal = function()
  local colors = require('ty.contrib.ui').colors()
  local nvim_set_hl = vim.api.nvim_set_hl
  require('portal').setup({
    log_level = 'error',
    query = {
      'grapple',
      'valid',
    },
    portal = {
      title = {
        --- When a portal is empty, render an default portal title
        render_empty = false,
      },
      body = {
        -- When a portal is empty, render an empty buffer body
        render_empty = false,
      },
    },
  })

  nvim_set_hl(0, 'PortalBorderForward', { fg = colors.portal_border_forward })
  nvim_set_hl(0, 'PortalBorderNone', { fg = colors.portal_border_none })
end

M.setup_leap = function()
  local leap = require('leap')
  local colors = require('ty.contrib.ui.theme').colors()

  leap.opts.highlight_unlabeled_phase_one_targets = true
  leap.opts.substitute_chars = {
    ['\r'] = '',
    [' '] = '␣',
  }
  leap.add_default_mappings()
  leap.init_highlight(true)

  local function update_hl()
    -- Greying out the search area
    vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
    -- lightspeed like hl
    vim.api.nvim_set_hl(0, 'LeapMatch', {
      fg = colors.leap_match_fg,
      bold = true,
      italic = true,
      undercurl = false,
      underline = true,
    })
    vim.api.nvim_set_hl(0, 'LeapLabelPrimary', {
      bg = colors.leap_label_primary_bg,
      fg = colors.leap_label_primary_fg,
      bold = false,
    })
    vim.api.nvim_set_hl(0, 'LeapLabelSecondary', {
      bg = colors.leap_label_secondary,
      fg = '#ffffff',
      bold = true,
      undercurl = true,
      underline = false,
    })
  end

  update_hl()

  vim.api.nvim_create_autocmd('OptionSet', {
    pattern = 'background',
    callback = function() update_hl() end,
  })
end

M.option_surround = {
  keymaps = {
    delete = 'dz',
  },
}

M.option_grapple = {
  log_level = 'error',
  scope = 'git',
  integrations = {
    resession = false,
  },
}

return M
