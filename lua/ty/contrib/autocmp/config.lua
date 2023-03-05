local M = {}

M.autocomplete = {
  select_first_on_enter = false,

  autopairs_rules = {
    'auto_jsx_closing',
  },
  autopairs = {
    disable_filetype = {
      -- ignore autopairs when input in TelescopePrompt
      'TelescopePrompt',
    },
  },
}

return M
