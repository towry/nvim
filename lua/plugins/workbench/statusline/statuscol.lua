local au = require('libs.runtime.au')

return {
  'luukvbaal/statuscol.nvim',
  event = au.user_autocmds.FileOpened_User,
  cond = function() return vim.fn.has('nvim-0.9.0') == 1 end,
  config = function()
    local statuscol = require('statuscol')
    local builtin = require('statuscol.builtin')

    statuscol.setup({
      separator = '│',
      relculright = true,
      setopt = true,
      segments = {
        {
          sign = { name = { 'GitSigns' }, maxwidth = 1, colwidth = 1, auto = false },
          click = 'v:lua.ScSa',
        },
        {
          sign = { name = { 'Diagnostic' }, maxwidth = 1, auto = false },
          click = 'v:lua.ScSa',
        },
        {
          sign = { name = { '.*' }, maxwidth = 1, colwidth = 1, auto = true },
        },
        { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
        { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
      },
    })
  end,
}
