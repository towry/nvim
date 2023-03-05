local M = {}

M.settings = {
  completion = {
    callSnippet = 'Replace',
  },
  Lua = {
    diagnostics = {
      globals = { 'vim', 'bit', 'packer_plugins' },
    },
  },
}

return M
