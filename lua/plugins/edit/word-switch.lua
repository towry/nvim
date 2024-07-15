local plug = require('userlib.runtime.pack').plug

return plug({
  {
    vscode = true,
    submodules = false,
    -- easily switch between word/text
    'AndrewRadev/switch.vim',
    keys = {
      {
        '<leader>t-',
        '<cmd>Switch<cr>',
        desc = 'Switch variables, false <==> true',
      },
    },
    cmd = 'Switch',
    config = function()
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
        { 'TODO',       'FIXME',       'NOTE' },
        { 'dark',       'light' },
        { 'production', 'development', 'test' },
        { 'soft',       'medium',      'hard' },
        { 'low',        'high' },
        -- git rebase -i
        { 'pick',       'squash' },
      }
    end,
  },
})
