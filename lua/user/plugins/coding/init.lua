return {
  {
    import = "user.plugins.coding.debugger"
  },
  {
    import = "user.plugins.coding.autocmp"
  },
  {
    'kylechui/nvim-surround',
    event = 'BufReadPost',
    opts = {
      keymaps = {
        delete = 'dz',
      },
    }
  },
}
