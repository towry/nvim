return {
  'ggandor/leap.nvim',
  dependencies = {
    'tpope/vim-repeat',
  },
  keys = { { 's' }, { 'S' }, { 'gs' }, { 'f' }, { 'F' }, { 'vs' }, { 'ds' } },
  config = function()
    local leap = require('leap')
    local au = require('libs.runtime.au')

    leap.opts.highlight_unlabeled_phase_one_targets = true
    leap.opts.substitute_chars = {
      ['\r'] = '',
      [' '] = '␣',
    }
    leap.add_default_mappings()
    leap.init_highlight(true)

    --- TODO: fix hl.
    local function update_hl()
      -- Greying out the search area
      vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
      -- -- lightspeed like hl
      -- vim.api.nvim_set_hl(0, 'LeapMatch', {
      --   fg = colors.leap_match_fg,
      --   bold = true,
      --   italic = true,
      --   undercurl = false,
      --   underline = true,
      -- })
      -- vim.api.nvim_set_hl(0, 'LeapLabelPrimary', {
      --   bg = colors.leap_label_primary_bg,
      --   fg = colors.leap_label_primary_fg,
      --   bold = false,
      -- })
      -- vim.api.nvim_set_hl(0, 'LeapLabelSecondary', {
      --   bg = colors.leap_label_secondary,
      --   fg = '#ffffff',
      --   bold = true,
      --   undercurl = true,
      --   underline = false,
      -- })
    end

    au.register_event(au.events.AfterColorschemeChanged, {
      name = 'update_leap_hl',
      immediate = true,
      callback = function()
        update_hl()
      end,
    })
  end,
}
