--LuaCC code block

require("user.plugins.essential")
require("user.plugins.theme")
require("user.plugins.dashboard")
require("user.plugins.cmdline")
require("user.plugins.autocmp")
require("user.plugins.debugger")
require("user.plugins.folding")
require("user.plugins.indent")
require("user.plugins.lsp")
require("user.plugins.statusline")
require("user.plugins.finder")
require("user.plugins.git")
require("user.plugins.terminal")
require("user.plugins.lang")
require("user.plugins.ui")
require("user.plugins.motion")
require("user.plugins.workflow")
require("plugin-extras.coding.copilot-nvim")
require("plugin-extras.coding.word-switch")

return require('libs.runtime.pack').repos
