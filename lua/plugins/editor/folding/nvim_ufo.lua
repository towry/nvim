return {
    'kevinhwang91/nvim-ufo',
    event = 'LspAttach',
    dependencies = {
        'kevinhwang91/promise-async',
    },
    config = function()
        local ufo = require('ufo')

        ufo.setup({
            fold_virt_text_handler = require('libs.folding').ufo_handler,
            -- close_fold_kinds = { "imports" }
        })
    end
}
