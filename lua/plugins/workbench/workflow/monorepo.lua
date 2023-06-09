return {
  "imNel/monorepo.nvim",
  keys = {
    {
      '<leader>em',
      [[<cmd>lua require("telescope").extensions.monorepo.monorepo()<cr>]],
      desc = 'Manage monorepo',
    },
    {
      '<leader>e$',
      [[<cmd>lua require("monorepo").toggle_project()<cr>]],
      desc = 'Toggle cwd as project'
    },
  },
  opts = {
    autoload_telescope = true,
  }
}
