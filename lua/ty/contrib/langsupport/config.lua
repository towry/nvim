local M = {}

M.treesitter = {
  ensure_installed = {
    'bash',
    'c',
    'cpp',
    'css',
    'dockerfile',
    'go',
    'gomod',
    'graphql',
    'html',
    'java',
    'javascript',
    'json',
    'jsonc',
    'lua',
    'python',
    'regex',
    'rust',
    'scss',
    'tsx',
    'typescript',
    'yaml',
  },
  enable_incremental_selection = false,
  enable_highlight = true,
  enable_indent = false,
  enable_yati = true,
  enable_rainbow = true,
  enable_context_commentstring = true,
  enable_refactor = false,
  enable_textobjects_move = true,
  enable_textsubjects = false,
}

M.colorizer = {
  enable = true,
  -- filetypes that colorizer should support.
  filetypes = {
    'html',
    'css',
    'javascript',
    'typescript',
    'typescriptreact',
    'javascriptreact',
    'lua',
    'sass',
    'scss',
    'less',
  },
  enable_tailwind_color = true,
}

return M
