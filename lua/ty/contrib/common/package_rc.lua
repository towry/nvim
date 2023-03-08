local M = {}

M.setup_telescope = require('ty.contrib.common.telescope_rc').setup
M.setup_legendary = require('ty.contrib.common.legendary_rc').setup
M.setup_mini = require('ty.contrib.common.mini').setup
M.init_mini = require('ty.contrib.common.mini').init
M.setup_whichkey = require('ty.contrib.common.whichkey_rc').setup

return M
