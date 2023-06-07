return {
  {
    'dstein64/vim-startuptime',
    cond = function()
      return vim.env.PROFILE == 1
    end,
    lazy = false,
  }
}
