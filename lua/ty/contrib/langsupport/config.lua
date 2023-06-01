local M = {}

M.treesitter = {
  ensure_installed = {
    'bash',
    'css',
    'html',
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
    'markdown',
    'markdown_inline',
  },
  enable_incremental_selection = false,
  enable_highlight = true,
  enable_indent = true,
  enable_yati = true,
  enable_rainbow = false,
  enable_context_commentstring = true,
  enable_refactor = false,
  enable_textobjects_move = true,
  enable_textsubjects = true,
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
