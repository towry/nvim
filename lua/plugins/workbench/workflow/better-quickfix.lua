return {
  -- https://github.com/kevinhwang91/nvim-bqf
  'kevinhwang91/nvim-bqf',
  ft = 'qf',
  dependencies = {
    { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
  },
}
