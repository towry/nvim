-- n('[tp', 'Jump to parent tag', cmd([[lua Ty.Func.navigate.jump_to_tag('parent')]]))
-- n('[tc', 'Jump to child tag', cmd([[lua Ty.Func.navigate.jump_to_tag('child')]]))
-- n('[t]', 'Jump to next tag', cmd([[lua Ty.Func.navigate.jump_to_tag('next')]]))
-- n('[t[', 'Jump to previous tag', cm
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
