return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "BufReadPost",
  enabled = true,
  opts = {
    max_lines = 3,
    mode = "cursor"
  },
  keys = {
    {
      '[c', '<cmd>lua require("treesitter-context").go_to_context()<cr>', desc = 'Treesitter Context: Go to context'
    }
  },
  config = function(_, opts)
    require('treesitter-context').setup(opts)
    vim.cmd([[hi TreesitterContextBottom gui=underline guisp=Grey]])
  end
}
