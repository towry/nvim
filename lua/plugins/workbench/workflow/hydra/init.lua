local cmdstr = require('libs.runtime.keymap').cmdstr

return {
  -- 'anuvyklack/hydra.nvim',
  'pze/hydra.nvim',
  keys = {
    {
      '<C-w>',
      cmdstr([[lua require("plugins.workbench.workflow.hydra.window").open_window_hydra(true)]]),
      desc = 'Window operations',
    }
  }
}
