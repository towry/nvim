local plug = require('libs.runtime.pack').plug

return plug({
  "echasnovski/mini.files",
  opts = {
    windows = {
      preview = true,
    },
    options = {
      -- Whether to use for editing directories
      -- Disabled by default in LazyVim because neo-tree is used for that
      use_as_default_explorer = false,
    },
  },
  keys = {
    {
      "<leader>ei",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (directory of current file)",
    },
    {
      "<leader>eI",
      function()
        require("mini.files").open(vim.loop.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },
  config = function(_, opts)
    require('mini.files').setup(opts)
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesWindowUpdate',
      callback = function(args) vim.wo[args.data.win_id].relativenumber = true end,
    })
  end
})
