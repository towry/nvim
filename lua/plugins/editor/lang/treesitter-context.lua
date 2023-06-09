return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "BufReadPost",
  enabled = true,
  opts = {
    max_lines = 3,
    mode = "cursor"
  },
}
