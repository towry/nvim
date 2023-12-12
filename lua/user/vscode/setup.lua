local vscode = require('vscode-neovim')
local keymap = require('userlib.runtime.keymap')
local set = keymap.set


--- keymaps
local _call = function(call_cmd) return "<cmd>lua require('vscode-neovim').call('" .. call_cmd .. "')<cr>" end
set({ 'x' }, '<leader>cf', _call('editor.action.formatSelection'), {
  desc = 'format selection',
})
set({ 'n' }, '<leader>cf', _call('prettier.forceFormatDocument'), {
  desc = 'format with prettier if prettier exists'
})
set({ 'n' }, 'KK', _call('editor.action.showDefinitionPreviewHover'), {
  desc = 'Show Definition Preview Hover',
})
set({ 'n' }, '<leader>cp', _call('editor.action.peekDefinition'), {
  desc = 'Peek Definition',
})
set({ 'n' }, '<leader>ch', _call('editor.showCallHierarchy'), {
  desc = 'Peek call hierarchy',
})
set({ 'n' }, '<leader>ci', _call('editor.action.peekImplementation'), {
  desc = 'Peek implementation',
})
--//
set({ 'n' }, '<leader>ff', _call('workbench.action.quickOpen'), {
  desc = 'Open file finder',
})
set({ 'n' }, '<leader>fs', _call('workbench.action.findInFiles'), {
  desc = 'Search in files',
})
set({ 'n' }, '<leader>fg', _call('workbench.action.findInFiles'), {
  desc = 'Search in files',
})
--// finder
set({ 'n' }, 'gh[', _call('workbench.action.editor.previousChange'), {
  desc = 'Previous change',
})
set({ 'n' }, 'gh]', _call('workbench.action.editor.nextChange'), {
  desc = 'Next change',
})
--// motion
set({ 'n' }, 'gha', _call('git.stage'), {
  desc = 'Stage change',
})
set({ 'n' }, 'ghs', _call('git.stage'), {
  desc = 'Stage change',
})
set({ 'n' }, '<leader>gs', _call('git.openChange'), {
  desc = 'Open git changes',
})
set({ 'n', }, 'ghb', _call('gitlens.toggleFileBlame'), {
  desc = 'Toggle file blame',
})
set({ 'n' }, 'ghr', _call('git.clean'), {
  desc = 'Git discard changes',
})
set({ 'n' }, '<leader>gc', _call('git.commit'), {
  desc = 'Git commit'
})
set({ 'n' }, '<leader>gg', _call('workbench.view.scm'), {
  desc = 'Show source control',
})

