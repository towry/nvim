local set = vim.keymap.set
local cmd = function(str) return '<cmd>' .. str .. '<cr>' end

local M = {}

local function setup_basic()
    set('n', '<C-U>', '<C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y>', {
        desc = "Smooth scrolling up"
    })
    set('n', '<C-D>', '<C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E>', {
        desc = 'Smooth scrolling down',
    })

    set('i', '<C-e>', '<End>', {
        desc = 'Insert mode: move to end of line',
    })
    set('n', '<C-z>', '<ESC> u', {
        desc = 'N: Undo, no more background key',
    })
    set('i', '<C-z>', '<ESC> u', {
        desc = 'I: Undo, no more background key',
    })

    -- works with kitty
    set('n', '<Char-0xAA>', cmd(':w'), {
        desc = 'N: Save current file by <command-s>',
    })
    set('i', '<Char-0xAA>', cmd('<ESC>:w'), {
        desc = 'I: Save current file by <command-s>',
    })

    set('n', '<ESC>', cmd('noh'), {
        desc = 'Clear search highlight',
    })
    set('v', '<', '<gv', {
        desc = 'Keep visual mode indenting, left',
    })
    set('v', '>', '>gv', {
        desc = 'Keep visual mode indenting, right',
    })
    set('v', '`', 'u', {
        desc = 'Case change in visual mode'
    })

    set({ 'v', 'i' }, '<F1>', cmd('wa'), {
        desc = 'Save all files',
    })

    -- yanks
    set('n', 'd', '"xd', {
        desc = 'Delete char and yank to register x',
    })
    set('n', 'D', '"xD', {
        desc = 'Delete to end of line and yank to register x',
    })
    set('v', 'd', '"xd', {
        desc = 'Delete char and yank to register x',
    })
    set('v', 'D', '"xD', {
        desc = 'Delete to end of line and yank to register x',
    })
    set('n', '<Char-0xAB>', '"*x', {
        desc = 'Cut chars and yank to register *',
        remap = false,
    })
    set('v', '<Char-0xAB>', '"*x', {
        desc = 'Cut chars and yank to register *',
        remap = false,
    })
    set('n', 'x', '"_x', {
        desc = 'Cut chars and do not yank to register',
    })
    set('n', 'X', '"_X', {
        desc = 'Cut chars and do not yank to register',
    })
    set('v', 'x', '"_x', {
        desc = 'Cut chars and do not yank to register',
    })
    set('v', 'X', '"_X', {
        desc = 'Cut chars and do not yank to register',
    })
    set('v', 'p', '"_dP', {
        desc = 'Do not yank on visual paste',
    })
    set('x', 'p', '"_dP', {
        desc = 'Do not yank on select paste',
    })

    ---gx
    if vim.fn.has('macunix') == 1 then
        set('n', 'gx', cmd('silent execute "!open " . shellescape("<cWORD>")'), {
            desc = 'Open file under cursor',
        })
    else
        set('n', 'gx', cmd('silent execute "!xdg-open " . shellescape("<cWORD>")'), {
            desc = 'Open file under cursor',
        })
    end

    -- n('H', 'Move to first non-blank character of the line', key('^'))
    -- n('L', 'Move to last non-blank character of the line', key('$', { '+noremap' }))
    -- n('Y', 'Yank to end of line', key('y$'))
    -- x('K', 'Move selected line / block of text in visual mode up', key(":move '<-2<CR>gv-gv"))
    -- x('J', 'Move selected line / block of text in visual mode down', key(":move '>+1<CR>gv-gv"))
    set('n', 'H', '^', {
        desc = 'Move to first non-blank character of the line',
    })
    set('n', 'L', '$', {
        desc = 'Move to last non-blank character of the line',
    })
    set('n', 'Y', 'y$', {
        desc = 'Yank to end of line',
    })
    set('v', 'K', ":move '<-2<CR>gv-gv", {
        desc = 'Move selected line / block of text in visual mode up',
    })
    set('v', 'J', ":move '>+1<CR>gv-gv", {
        desc = 'Move selected line / block of text in visual mode down',
    })
end


function M.setup()
    setup_basic()
end

return M
