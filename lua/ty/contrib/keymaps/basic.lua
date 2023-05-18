--- keymappings for neovim for basic usage.
local autocmd = require('ty.core.autocmd')
local has_plugin = require('ty.core.utils').has_plugin
local keymap = require('ty.core.keymap')
local n, i, v, x, ni, nxv, cmd, key =
    keymap.nmap, keymap.imap, keymap.vmap, keymap.xmap, keymap.nimap, keymap.nxv, keymap.cmd, keymap.key

-- h:scroll-smooth
n('<C-U>', 'Smooth scroll', key('<C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y>'))
n('<C-D>', 'Smooth scroll', key('<C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E>'))

i('<C-e>', 'Insert mode: move to end of line', key('<End>'))
n('<C-z>', 'N: Undo, no more background key', key('<ESC> u'))
i('<C-z>', 'I: Undo, no more background key', key('<ESC> u'))
v('<D-`>', 'Case change in visual mode', key('U'))
n('<Char-0xAA>', 'N: Save current file by <command-s>', cmd('w'))
i('<Char-0xAA>', 'I: Save current file by <command-s>', cmd('w'))
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
n('<leader><space>', 'Mark jump position', cmd('normal! m\'', { '+noremap', '+nowait' }))

-- fn keys
-- move fn key mappings in 'must_have' to here and use above style.
ni('<F1>', 'Save all file by F1', cmd('wa'))
-- ni('<F7>', 'Toggle NvimTree', cmd('lua Ty.Func.explorer.toggle_nvim_tree()'))
-- ni('<F8>', 'Open Project files', cmd('lua Ty.Func.explorer.project_files()'))
-- ni('<F9>', 'Grep search', cmd([[lua require('telescope').extensions.live_grep_args.live_grep_args()]]))
-- ni('<F10>', 'Resume telescope pickers', cmd([[lua require('telescope.builtin').resume()]]))
-- ni('<F19>', 'Toggle find file', cmd('lua Ty.Func.explorer.toggle_nvim_tree_find_file()'))
-- ni('<F20>', 'Open old files', cmd('lua Ty.Func.explorer.oldfiles({ cwd_only = true })'))

-- yanks.
n('d', 'Delete char and yank to register x', key('"xd'))
n('D', 'Delete to end of line and yank to register x', key('"xD'))
v('d', 'Delete char and yank to register x', key('"xd'))
v('D', 'Delete to end of line and yank to register x', key('"xD'))
n('<Char-0xAB>', 'Cut chars and yank to register *', key('"*x', { '-remap' }))
v('<Char-0xAB>', 'Cut chars and yank to register *', key('"*x', { '-remap' }))
n('x', 'Cut chars and do not yank to register', key('"_x'))
n('X', 'Cut chars and do not yank to register', key('"_X'))
v('x', 'Cut chars and do not yank to register', key('"_x'))
v('X', 'Cut chars and do not yank to register', key('"_X'))
v('p', 'Do not yank on visual paste', key('"_dP'))
x('p', 'Do not yank on select paste', key('"_dP'))

-- prefix: g
if vim.fn.has('macunix') == 1 then
  n('gx', 'Open link at cursor', cmd('silent execute "!open " . shellescape("<cWORD>")'))
else
  n('gx', 'Open link at cursor', cmd('silent execute "!xdg-open " . shellescape("<cWORD>")'))
end
if has_plugin('junegunn/vim-easy-align') then nxv('ga', 'Easy align', key('<Plug>(EasyAlign)')) end
autocmd.listen({ autocmd.EVENTS.on_gitsigns_attach }, function(ctx)
  n('gh', 'Gitsigns',
    cmd("lua require('ty.contrib.keymaps.hydra.git').open_git_signs_hydra()", { buffer = ctx.buf }))
end)

n('H', 'Move to first non-blank character of the line', key('^'))
n('L', 'Move to last non-blank character of the line', key('$', { '+noremap' }))
n('Y', 'Yank to end of line', key('y$'))
x('K', 'Move selected line / block of text in visual mode up', key(":move '<-2<CR>gv-gv"))
x('J', 'Move selected line / block of text in visual mode down', key(":move '>+1<CR>gv-gv"))

--- '[' and ']' keys
-- html tags
n('[tp', 'Jump to parent tag', cmd([[lua Ty.Func.navigate.jump_to_tag('parent')]]))
n('[tc', 'Jump to child tag', cmd([[lua Ty.Func.navigate.jump_to_tag('child')]]))
n('[t]', 'Jump to next tag', cmd([[lua Ty.Func.navigate.jump_to_tag('next')]]))
n('[t[', 'Jump to previous tag', cmd([[lua Ty.Func.navigate.jump_to_tag('prev')]]))
-- todo jump
n(']td', 'Jump to next todo', cmd([[lua Ty.Func.editor.jump_to_todo('next')]]))
n('[td', 'Jump to previous todo', cmd([[lua Ty.Func.editor.jump_to_todo('prev')]]))

-- functional keys.
n('<leader>s', 'Search and replace')
nxv('<leader>sp', 'Search and replace', cmd('lua Ty.Func.explorer.search_and_replace()'))
nxv(
  '<leader>sP',
  'Search and replace cword in current file',
  cmd('lua Ty.Func.explorer.search_and_replace_cword_in_buffer()')
)
vim.keymap.set('n', '<C-p>', function()
  if vim.bo.buftype ~= "" then
    -- not work.
    return vim.api.nvim_feedkeys('<C-p>', 'n', true)
  end
  require('ty.contrib.keymaps.legendary').open_legendary()
end)

n('<leader>t', 'Tool, Toggle')
n('<leader>t-', 'Switch variables, false <==> true', cmd([[Switch]]))
n('<leader>tq', 'Quick list', cmd('lua Ty.Func.editor.toggle_qf()'))

n("<leader>/", "Outline, Terms")
n("<leader>//", "Find terms", cmd([[Telescope termfinder find]]))
n('<leader>/o', '[/] Toggle outline', cmd([[lua Ty.Func.explorer.toggle_outline()]]))
-- gits
n('<leader>g', 'Git')
n('<leader>gg', 'Fugitive Git', key([[:Git<CR>]]))
n('<leader>ga', 'Git add current', cmd([[!git add %:p]]))
n('<leader>gA', 'Git add all', cmd([[!git add .]]))
n('<leader>gb', 'Git open blame', cmd([[lua Ty.Func.git.open_blame()]]))
n('<leader>gB', 'Git branchs', cmd([[Telescope git_branches]]))
n('<leader>gD', 'Git file history', cmd([[lua Ty.Func.git.toggle_file_history()]]))
n('<leader>gd', 'Git changes', cmd([[lua Ty.Func.git.toggle_git_changes()]]))
n('<leader>gv', 'Git commits', cmd([[lua Ty.Func.term.toggle_tig()]]))
n('<leader>gV', 'Git file history', cmd([[lua Ty.Func.git.toggle_tig_file_history()]]))
n('<leader>gl', 'Lazygit', cmd([[LazyGit]]))
n('<leader>gc', 'Open git conflict menus',
  cmd("lua require('ty.contrib.keymaps.hydra.git').open_git_conflict_hydra()", { "+noremap" }))
-- explores
n('<leader>e', 'Explorer')
n('<leader>ef', 'Open Project files', cmd('lua Ty.Func.explorer.project_files()'))
n('<leader>et', 'Toggle explore tree', cmd([[lua Ty.Func.explorer.toggle_nvim_tree()]]))
n('<leader>ee', 'Resume telescope pickers', cmd([[lua require('telescope.builtin').resume()]]))
n('<leader>er', 'Open recent files', cmd('lua Ty.Func.explorer.oldfiles({ cwd_only = true })'))
n('<leader>e.', 'Locate current file in tree', cmd('lua Ty.Func.explorer.nvim_tree_find_file()'))
n('<leader>es', 'Grep search', cmd([[lua require('telescope').extensions.live_grep_args.live_grep_args()]]))
n('<leader>el', 'Find folders', cmd('lua Ty.Func.explorer.find_folder()'))
-- n('<leader>eS', 'Grep search under word', cmd([[lua require('telescope').extensions.live_grep_args.live_grep_args()]]))

--- folding.
if has_plugin('nvim-ufo') then
  n('zR', 'Open all folds', cmd([[lua require('ufo').openAllFolds]]))
  n('zM', 'Close all folds', cmd([[lua require('ufo').closeAllFolds]]))
  n('zr', 'Open folds except kinds', cmd([[lua require('ufo').openFoldsExceptKinds]]))
end

--- portal and grapple
n('<leader>b', 'Buffer')
if has_plugin('grapple.nvim') then n('<leader>bg', 'Toggle grapple mark', cmd([[GrappleToggle]])) end
if has_plugin('portal.nvim') then
  n('<M-o>', 'Portal jump backward', cmd([[lua Ty.Func.navigate.portal_backward()]]))
  n('<M-i>', 'Portal jump forward', cmd([[lua Ty.Func.navigate.portal_forward()]]))
end
if has_plugin('harpoon') then
  n('<leader>bb', 'Open harpoon ui', cmd([[lua require('harpoon.ui').toggle_quick_menu()]]))
  n('<leader>bm', 'Mark buffer with harpoon', cmd([[lua require('harpoon.mark').add_file()]]))
  n('<leader>bn', 'Harpoon next mark', cmd([[lua require('harpoon.ui').nav_next()]]))
  n('<leader>bp', 'Harpoon prev mark', cmd([[lua require('harpoon.ui').nav_prev()]]))
end
n('<leader>b]', 'Next unsaved buffer', cmd([[lua Ty.Func.navigate.next_unsaved_buf()]]))
n('<leader>b[', 'Prev unsaved buffer', cmd([[lua Ty.Func.navigate.prev_unsaved_buf()]]))
n('<leader>bd', 'Discard buffer changes', key([[:e!<CR>]]))
n('<leader>bx', 'Close buffer and window', cmd('lua Ty.Func.buffer.close_bufwin()'))

n('<leader>z', 'Copilot, ...')
if has_plugin('copilot.vim') then n('<leader>zp', 'Open github copilot panel', cmd([[Copilot panel]])) end
