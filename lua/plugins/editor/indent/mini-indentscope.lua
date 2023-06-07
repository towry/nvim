return {
  'echasnovski/mini.indentscope',
  event = {
    'BufReadPre', 'BufNewFile',
  },
  config = function()
    require('mini.indentscope').setup({
      symbol = '│',
      options = {
        try_as_border = true,
      },
    })
  end,
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  end,
}
