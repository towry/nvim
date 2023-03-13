local M = {}

function M.setup()
  -- TODO: create autocmd for diffrerent files.
  vim.g.switch_custom_definitions = {
    { 'top',        'bottom' },
    { 'left',       'right' },
    { 'width',      'height' },
    { 'padding',    'margin' },
    { 'const',      'let' },
    { ',',          ';' },
    { "'",          '"',           '`' },
    { 'solid',      'dashed' },
    { '+',          '-' },
    { 'always',     'auto',        'never' },
    { '=',          ':' },
    { 'before',     'after' },
    { 'back',       'front' },
    { 'start',      'stop' },
    { 'yes',        'no' },
    { 'error',      'warn',        'info', 'debug' },
    { 'TODO',       'FIXME' },
    { 'dark',       'light' },
    { 'production', 'development', 'test' },
    { "soft",       "medium",      "hard" },
  }
end

return M
