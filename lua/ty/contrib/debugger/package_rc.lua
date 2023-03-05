local M = {}

M.setup_dap = require('ty.contrib.debugger.dap').setup
M.setup_neotest = require('ty.contrib.debugger.neotest').setup
M.init_neotest = require('ty.contrib.debugger.neotest').init

return M
