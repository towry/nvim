local pack = require('userlib.runtime.pack')
local cmd_modcall = require('userlib.runtime.keymap').cmd_modcall

pack.plug({
  'kevinhwang91/nvim-ufo',
  event = 'LspAttach',
  dependencies = {
    'kevinhwang91/promise-async',
  },
  keys = {
    {
      'zR', cmd_modcall('ufo', 'openAllFolds()'), desc = 'Open all folds',
    },
    {
      'zM', cmd_modcall('ufo', 'closeAllFolds()'), desc = 'Close all folds',
    },
    {
      'zr', cmd_modcall('ufo', 'openFoldsExceptKinds()'), desc = 'Open folds except kinds',
    }
  },
  config = function()
    local ufo = require('ufo')

    ufo.setup({
      fold_virt_text_handler = require('userlib.folding').ufo_handler,
      -- close_fold_kinds = { "imports" }
    })
  end
}
)
