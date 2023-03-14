--- keymappings for neovim for basic usage.
--- Should be in alphabetical order.
local autocmd = require('ty.core.autocmd')
local has_plugin = require('ty.core.utils').has_plugin
local keymap = require('ty.core.keymap')
local n, i, v, x, ni, nxv, cmd, key =
keymap.nmap, keymap.imap, keymap.vmap, keymap.xmap, keymap.nimap, keymap.nxv, keymap.cmd, keymap.key

i('<C-e>', 'Insert mode: move to end of line', key('<End>'))
n('<C-z>', 'N: Undo, no more background key', key('<ESC> u'))
i('<C-z>', 'I: Undo, no more background key', key('<ESC> u'))
v('<A-`>', 'Case change in visual mode', key('U'))
n('<A-s>', 'N: Save current file by <command-s>', cmd('w'))
i('<A-s>', 'I: Save current file by <command-s>', cmd('w'))
n('<ESC>', 'Clear search highlight', cmd('noh'))
v('<', 'Keep visual mode indenting, left', key('<gv'))
v('>', 'Keep visual mode indenting, right', key('>gv'))
v('`', 'Case change in visual mode', key('u'))
-- window resize/focus/swap.
-- A: option key.
n('<A-h>', 'Resize window to left', cmd('lua Ty.Func.buffer.resize_window_by("left")'))
n('<A-j>', 'Resize window to down', cmd('lua Ty.Func.buffer.resize_window_by("down")'))
n('<A-k>', 'Resize window to up', cmd('lua Ty.Func.buffer.resize_window_by("up")'))
n('<A-l>', 'Resize window to right', cmd('lua Ty.Func.buffer.resize_window_by("right")'))
n('<C-h>', 'Move cursor to left window', cmd('lua Ty.Func.buffer.move_cursor_to_window("left")'))
n('<C-j>', 'Move cursor to down window', cmd('lua Ty.Func.buffer.move_cursor_to_window("down")'))
n('<C-k>', 'Move cursor to up window', cmd('lua Ty.Func.buffer.move_cursor_to_window("up")'))
n('<C-l>', 'Move cursor to right window', cmd('lua Ty.Func.buffer.move_cursor_to_window("right")'))
n('<C-w>', 'Window operations', cmd('lua require("ty.contrib.keymaps.hydra.window").open_window_hydra(true)'))

n('<Tab>', 'List Buffers', cmd('lua Ty.Func.explorer.open_buffers()'))
n('<S-Tab>', 'Go to previous edited Buffer', key(':e #<cr>'))
n('<S-q>', 'Quit current buffer', cmd('lua Ty.Func.buffer.close_buffer()'))
-- Move between buffers
-- for inx = 1, 9 do
--   n(
--     '<Space>' .. inx,
--     'Move to buffer by index ' .. inx,
--     cmd('lua Ty.Func.buffer.switch_to_buffer_by_index(' .. inx .. ')')
--   )
-- end

-- fn keys
-- move fn key mappings in 'must_have' to here and use above style.
ni('<F1>', 'Save all file by F1', cmd('wa'))
ni('<F7>', 'Toggle NvimTree', cmd('lua Ty.Func.explorer.toggle_nvim_tree()'))
ni('<F8>', 'Open Project files', cmd('lua Ty.Func.explorer.project_files()'))
ni('<F9>', 'Grep search', cmd([[lua require('telescope').extensions.live_grep_args.live_grep_args()]]))
ni('<F10>', 'Resume telescope pickers', cmd([[lua require('telescope.builtin').resume()]]))
ni('<F19>', 'Toggle find file', cmd('lua Ty.Func.explorer.toggle_nvim_tree_find_file()'))
ni('<F20>', 'Open old files', cmd('lua Ty.Func.explorer.oldfiles({ cwd_only = true })'))

-- yanks.
n('d', 'Delete char and yank to register x', key('"xd'))
n('D', 'Delete to end of line and yank to register x', key('"xD'))
v('d', 'Delete char and yank to register x', key('"xd'))
v('D', 'Delete to end of line and yank to register x', key('"xD'))
n('<A-x>', 'Cut chars and yank to register *', key('"*x', { '-remap' }))
v('<A-x>', 'Cut chars and yank to register *', key('"*x', { '-remap' }))
n('x', 'Cut chars and do not yank to register', key('"_x'))
n('X', 'Cut chars and do not yank to register', key('"_X'))
v('x', 'Cut chars and do not yank to register', key('"_x'))
v('X', 'Cut chars and do not yank to register', key('"_X'))
v('p', 'Do not yank on visual paste', key('"_dP'))
x('p', 'Do not yank on select paste', key('"_dP'))

if vim.fn.has('macunix') == 1 then
  n('gx', 'Open link at cursor', cmd('silent execute "!open " . shellescape("<cWORD>")'))
else
  n('gx', 'Open link at cursor', cmd('silent execute "!xdg-open " . shellescape("<cWORD>")'))
end
if has_plugin('junegunn/vim-easy-align') then nxv('ga', 'Easy align', key('<Plug>(EasyAlign)')) end
autocmd.listen({ autocmd.EVENTS.on_gitsigns_attach }, function(ctx)
  n('[gh', 'Git next hunk', cmd('lua Ty.Func.git.next_hunk()'))
  n(']gh', 'Git prev hunk', cmd('lua Ty.Func.git.prev_hunk()'))
  n('gh', 'Gitsigns',
    cmd("lua require('ty.contrib.keymaps.hydra.git').open_git_signs_hydra()", { buffer = ctx.buf }))
end)

n('H', 'Move to first non-blank character of the line', key('^'))
n('L', 'Move to last non-blank character of the line', key('$'))
n('Y', 'Yank to end of line', key('y$'))
x('K', 'Move selected line / block of text in visual mode up', key(":move '<-2<CR>gv-gv"))
x('J', 'Move selected line / block of text in visual mode down', key(":move '>+1<CR>gv-gv"))

--- '[' and ']' keys
-- html tags
n('[tp', 'Jump to parent tag', cmd([[lua Ty.Func.navigate.jump_to_tag('parent')]]))
n('[tc', 'Jump to child tag', cmd([[lua Ty.Func.navigate.jump_to_tag('child')]]))
n('[t[', 'Jump to next tag', cmd([[lua Ty.Func.navigate.jump_to_tag('next')]]))
n('[t]', 'Jump to previous tag', cmd([[lua Ty.Func.navigate.jump_to_tag('prev')]]))
-- todo jump
n('[td', 'Jump to next todo', cmd([[lua Ty.Func.editor.jump_to_todo('next')]]))
n(']td', 'Jump to previous todo', cmd([[lua Ty.Func.editor.jump_to_todo('prev')]]))

-- functional keys.
n('<leader>s', 'Search and replace')
nxv('<leader>sp', 'Search and replace', cmd('lua Ty.Func.explorer.search_and_replace()'))
nxv(
  '<leader>sP',
  'Search and replace cword in current file',
  cmd('lua Ty.Func.explorer.search_and_replace_cword_in_buffer()')
)
n('<C-p>', 'Open legendary', cmd([[lua require('ty.contrib.keymaps.legendary').open_legendary()]]))
-- n('<leader>wv', 'Split buffer right', key('<C-W>v'))
-- n('<leader>wV', 'Split buffer bottom', key('<C-W>s'))
n('<leader>q', 'Open quick list', cmd('lua Ty.Func.editor.toggle_qf()'))
n('<leader>x', 'Close buffer and window', cmd('bdelete'))
n('<leader>F', 'Find folders', cmd('lua Ty.Func.explorer.find_folder()'))
n('<leader>t', 'Tool|Toggle')
n('<leader>t-', 'Switch variables, false <==> true', cmd([[Switch]]))
n("<leader>/", "Outline|Git")
n('<leader>/o', '[/] Toggle outline', cmd([[lua Ty.Func.explorer.toggle_outline()]]))
-- gits
n('<leader>/g', 'Git operations')
n('<leader>/ga', 'Git add current', cmd([[!git add %:p]]))
n('<leader>/gA', 'Git add all', cmd([[!git add .]]))
n('<leader>/gb', 'Git open blame', cmd([[lua Ty.Func.git.open_blame()]]))
n('<leader>/gB', 'Git branchs', cmd([[Telescope git_branches]]))
n('<leader>/gD', 'Git file history', cmd([[lua Ty.Func.git.toggle_file_history()]]))
n('<leader>/gd', 'Git changes', cmd([[lua Ty.Func.git.toggle_git_changes()]]))
n('<leader>/gv', 'Git commits', cmd([[GV]]))
n('<leader>/gg', 'Lazygit', cmd([[LazyGit]]))
n('<leader>/gc', 'Open git conflict menus',
  cmd("lua require('ty.contrib.keymaps.hydra.git').open_git_conflict_hydra()", { "+noremap" }))


--- folding.
if has_plugin('nvim-ufo') then
  n('zR', 'Open all folds', cmd([[lua require('ufo').openAllFolds]]))
  n('zM', 'Close all folds', cmd([[lua require('ufo').closeAllFolds]]))
  n('zr', 'Open folds except kinds', cmd([[lua require('ufo').openFoldsExceptKinds]]))
end

--- portal and grapple
if has_plugin('grapple.nvim') then n('<leader>bg', 'Toggle grapple mark', cmd([[GrappleToggle]])) end
if has_plugin('portal.nvim') then
  n('<M-o>', 'Portal jump backward', cmd([[lua Ty.Func.navigate.portal_backward()]]))
  n('<M-i>', 'Portal jump forward', cmd([[lua Ty.Func.navigate.portal_forward()]]))
end
if has_plugin('harpoon') then
  n('<leader>bm', 'Mark buffer with harpoon', cmd([[lua require('harpoon.mark').add_file()]]))
  n('<leader>bn', 'Harpoon next mark', cmd([[lua require('harpoon.ui').nav_next()]]))
  n('<leader>bp', 'Harpoon prev mark', cmd([[lua require('harpoon.ui').nav_prev()]]))
end

n('<leader>z', 'Copilot|...')
if has_plugin('copilot.vim') then n('<leader>zp', 'Open github copilot panel', cmd([[Copilot panel]])) end
--[[
A = {  },
a = { "<cmd>LazyGitFilter<CR>", "commits" },
C = { "<cmd>lua require('towry.utils.plug-telescope').my_git_bcommits()<CR>", "buffer commits (Telescope)" },
c = { "<cmd>LazyGitFilterCurrentFile<CR>", "buffer commits" },
m = { "blame line" },
s = { '<cmd>lua require("towry.plugins.plug-git").toggle_status()<CR>', 'status' },
]]
