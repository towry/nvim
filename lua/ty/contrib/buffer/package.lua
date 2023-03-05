local pack = require('ty.core.pack').buffer

pack({
  's1n7ax/nvim-window-picker',
  pin = true,
  ImportOption = 'window_picker',
})

pack({ 'mhinz/vim-sayonara', cmd = 'Sayonara' })
pack({ 'moll/vim-bbye', cmd = { 'Bdelete', 'Bwipeout' } })

pack({
  'kwkarlwang/bufresize.nvim',
  config = true,
})
pack({
  'mrjones2014/smart-splits.nvim',
  -- keys = { '<C-j>', '<C-h>', '<C-k>', '<C-l>', '<A-j>', '<A-h>', '<A-k>', '<A-l>' },
  dependencies = {
    'kwkarlwang/bufresize.nvim',
  },
  ImportConfig = 'smart_splits',
})
