local M = {}

M.settings = {
  completion = {
    callSnippet = 'Replace',
  },
  Lua = {
    workspace = {
      checkThirdParty = false,
    },
    hint = {
      enable = true,
    },
    runtime = {
      pathStrict = true,
    },
    format = {
      enable = true,
      defaultConfig = {
        indent_style = 'space',
        indent_size = '2',
      },
    },
  },
}

return M
