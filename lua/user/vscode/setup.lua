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
set({ 'n' }, '<leader>ff', _call('workbench.action.quickOpen'), {
  desc = 'Open file finder',
})
set({ 'n' }, '<leader>fs', _call('workbench.action.findInFiles'), {
  desc = 'Search in files',
})
set({ 'n' }, '<leader>fg', _call('workbench.action.findInFiles'), {
  desc = 'Search in files',
})
