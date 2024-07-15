--LuaCC code block

require('user.plugins.essential')
-- basic
require('user.plugins.cmdline')
require('user.plugins.git')
require('user.plugins.theme')
require('user.plugins.terminal')
if vim.cfg.edit__cmp_provider ~= 'coc' then
  require('user.plugins.lsp')
end
if not vim.g.is_start_as_merge_tool then
  require('user.plugins.indent')
  require('user.plugins.debugger')
  require('user.plugins.autocmp')
  require('user.plugins.statusline')
  require('user.plugins.finder')
  require('user.plugins.lang')
  require('user.plugins.ui')
  require('user.plugins.motion')
end
require('user.plugins.workflow')
--- extras and lazy
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
