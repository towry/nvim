return {
  --- In the SSR float window you can see the placeholder
  --- search code, you can replace part of it with wildcards.
  --- A wildcard is an identifier starts with $, like $name.
  --- A $name wildcard in the search pattern will match any
  --- AST node and $name will reference it in the replacement.
  "cshuaimin/ssr.nvim",
  module = "ssr",
  keys = {
    {
      '<leader>sr',
      '<cmd>lua require("ssr").open()<cr>',
      mode = { 'n', 'x' },
      desc = 'Replace with Treesitter structure(SSR)',
    }
  },
  opts = {
    border = "rounded",
    min_width = 50,
    min_height = 5,
    max_width = 120,
    max_height = 25,
    keymaps = {
      close = "q",
      next_match = "n",
      prev_match = "N",
      replace_confirm = "<cr>",
      replace_all = "<S-CR>",
    },
  },
}
