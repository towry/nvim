-- Use the w, e, b motions like a spider. Move by subwords and skip insignificant punctuation.
-- vim.keymap.set({"n", "o", "x"}, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
-- vim.keymap.set({"n", "o", "x"}, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
-- vim.keymap.set({"n", "o", "x"}, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
-- vim.keymap.set({"n", "o", "x"}, "ge", "<cmd>lua require('spider').motion('ge')<CR>", { desc = "Spider-ge" })
return {
  "chrisgrieser/nvim-spider",
  opts = {
    skipInsignificantPunctuation = true
  },
  lazy = true,
  keys = {
    {
      'w', "<cmd>lua require('spider').motion('w')<CR>", desc = "Spider-w", mode = { 'n', 'o', 'x' }
    },
    {
      'e', "<cmd>lua require('spider').motion('e')<CR>", desc = "Spider-e", mode = { 'n', 'o', 'x' }
    },
    {
      'b', "<cmd>lua require('spider').motion('b')<CR>", desc = "Spider-b", mode = { 'n', 'o', 'x' }
    },
    {
      'ge', "<cmd>lua require('spider').motion('ge')<CR>", desc = "Spider-ge", mode = { 'n', 'o', 'x' },
    }
  }
}
