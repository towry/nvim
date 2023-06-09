local cmd = require('libs.runtime.keymap').cmdstr

return {
  -- jump html tags.
  'harrisoncramer/jump-tag',
  keys = {
    {
      '[tp', cmd([[lua require('jump-tag').jumpParent()]]), desc = 'Jump to parent tag',
    },
    {
      '[tc', cmd([[lua require('jump-tag').jumpChild()]]), desc = 'Jump to child tag'
    },
    {
      '[t]', cmd([[lua require('jump-tag').jumpNextSibling()]]), desc = 'Jump to next tag'
    },
    {
      '[t[', cmd([[lua require('jump-tag').jumpPrevSibling()]]), desc = 'Jump to prev tag'
    }
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
}
