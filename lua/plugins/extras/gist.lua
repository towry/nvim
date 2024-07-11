local plug = require('userlib.runtime.pack').plug

return plug({
  'Rawnly/gist.nvim',
  cmd = { 'GistCreate', 'GistCreateFromFile', 'GistsList' },
  config = true,
})
