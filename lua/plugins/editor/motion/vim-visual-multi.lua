return {
  -- https://github.com/mg979/vim-visual-multi/wiki/Quick-start
  'mg979/vim-visual-multi',
  enabled = function() return false end,
  keys = { { 'v', 'V' } },
  config = function() vim.g.VM_leader = '<space>' end,
}
