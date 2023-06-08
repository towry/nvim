return {
  'michaelb/sniprun',
  build = 'sh ./install.sh',
  cmd = {
    'SnipRun',
    'SnipInfo',
    'SnipReset',
    'SnipClose',
    'SnipReplMemoryClean',
    'SnipLive',
  },
  keys = {
    { '<leader>rf', '<cmd>lua require("plugins.workbench.workflow.hydra.sniprun").open()<cr>',
      { desc = 'Open sniprun', mode = { 'n' } } },
  },
  -- https://michaelb.github.io/sniprun/sources/README.html#installation
  opts = {
    display = {
      "Classic", --# display results in the command-line  area
      "VirtualTextOk", --# display ok results as virtual text (multiline is shortened)
    },
  },
  init = function()
    vim.keymap.set('v', 'f', '<cmd>lua require("plugins.workbench.workflow.hydra.sniprun").open_visual()<cr>', {
      desc = 'Open sniprun'
    })
  end,
}
