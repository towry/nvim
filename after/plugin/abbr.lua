local au = require('userlib.runtime.au')

au.on_verylazy(function()
  ---- create abbreviations for command line.
  --- @param abbr string
  --- @param expand string
  local setca = function(abbr, expand)
    vim.api.nvim_set_keymap('ca', abbr, expand, { expr = false })
  end

  setca('avo', 'vertical Oil')
  setca('alp', 'Lazy profile')
  setca('ad', 'Dispatch')
  setca('asb', 'ScratchBuffer')
end)
