local cmd_modcall = require('libs.runtime.keymap').cmd_modcall

return {
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
      fold_virt_text_handler = require('libs.folding').ufo_handler,
      -- close_fold_kinds = { "imports" }
    })
  end
}
