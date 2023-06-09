return {
  -- https://github.com/stevearc/overseer.nvim
  'stevearc/overseer.nvim',
  dependencies = {
    "mfussenegger/nvim-dap"
  },
  cmd = { 'Grep', 'OverseerRun', 'OverseerOpen', 'OverseerToggle', 'OverseerClose', 'OverseerSaveBundle',
    'OverseerLoadBundle',
    'OverseerDeleteBundle', 'OverseerRunCmd', 'OverseerInfo', 'OverseerBuild', 'OverseerQuickAction',
    'OverseerTaskAction', 'OverseerClearCache' },
  keys = {
    { '<leader>rot', '<cmd>OverseerToggle!<cr>',      desc = 'Toggle' },
    { '<leader>roo', '<cmd>OverseerOpen!<cr>',        desc = 'Open' },
    { '<leader>ror', '<cmd>OverseerRun<cr>',          desc = 'Run' },
    { '<leader>roR', '<cmd>OverseerRunCmd<cr>',       desc = 'Run cmd' },
    { '<leader>roc', '<cmd>OverseerClose<cr>',        desc = 'Close' },
    { '<leader>ros', '<cmd>OverseerSaveBundle<cr>',   desc = 'Save bundle' },
    { '<leader>rol', '<cmd>OverseerLoadBundle<cr>',   desc = 'Load bundle' },
    { '<leader>rod', '<cmd>OverseerDeleteBundle<cr>', desc = 'Delete bundle' },
    { '<leader>roi', '<cmd>OverseerInfo<cr>',         desc = 'Info' },
    { '<leader>rob', '<cmd>OverseerBuild<cr>',        desc = 'Build' },
    { '<leader>roq', '<cmd>OverseerQuickAction<cr>',  desc = 'Quick action' },
    { '<leader>roT', '<cmd>OverseerTaskAction<cr>',   desc = 'Task action' },
    { '<leader>roC', '<cmd>OverseerClearCache<cr>',   desc = 'Clear cache' },
  },
  opts = {
    -- https://github.com/stevearc/overseer.nvim/blob/master/doc/reference.md#setup-options
    -- strategy = "terminal",
    strategy = "jobstart",
    templates = { "builtin" },
    auto_detect_success_color = true,
    dap = true,
    task_launcher = {
      bindings = {
        n = {
          ["<leader>c"] = "Cancel",
        },
      },
    },
  },
  config = function(_, opts)
    local overseer = require("overseer")
    overseer.setup(opts)
    -- if has_dap then
    --   require("dap.ext.vscode").json_decode = require("overseer.util").decode_json
    -- end
  end
}
