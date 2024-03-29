--LuaCC code block

require('user.plugins.essential')
--- basic
require('user.plugins.cmdline')
require('user.plugins.autocmp')
require('user.plugins.debugger')
require('user.plugins.theme')
require('user.plugins.folding')
require('user.plugins.indent')
if not vim.cfg.edit__use_coc then
  require('user.plugins.lsp')
end
require('user.plugins.statusline')
require('user.plugins.finder')
require('user.plugins.git')
require('user.plugins.terminal')
require('user.plugins.lang')
require('user.plugins.ui')
require('user.plugins.motion')
require('user.plugins.workflow')
--- extras
require('plugin-extras.workbench.neo-tree')
require('plugin-extras.coding.word-switch')
require('plugin-extras.coding.leetcode')
require('plugin-extras.coding.coc')
require('plugin-extras.workflow.zenmode')
require('plugin-extras.tools.profile')
require('plugin-extras.tools.games')
require('plugin-extras.ui.trail_blazer')
require('plugin-extras.tools.carbon')
require('plugin-extras.tools.gist')
require('plugin-extras.tools.obsidian')
require('plugin-extras.tools.ai')

return require('userlib.runtime.pack').repos()
