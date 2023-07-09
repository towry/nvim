local au = require('userlib.runtime.au')
local keymap = require('userlib.runtime.keymap')
local set, cmd, cmd_modcall = keymap.set, keymap.cmdstr, keymap.cmd_modcall

local M = {}

local function setup_basic()
  --- quickly go into cmd
  set('n', '<C-;>', ':<C-u>', {
    expr = false,
    noremap = true,
  })
  set('n', '<localleader>n', function()
    require('userlib.workflow.run-normal-keys')()
  end, {
    noremap = true,
    silent = false,
    desc = 'execute normal keys',
  })
  set('n', '<leader>rs', ':lua require("userlib.workflow.run-shell-cmd")()<cr>', {
    silent = true,
    noremap = true,
    desc = 'run shell command',
  })
  set('i', '<C-;>', '<esc>:<C-u>', {
    expr = false,
    noremap = true,
    desc = "Enter cmdline easily"
  })
  --- command line history.
  set('c', '<C-;>', function()
    return [[lua require('userlib.telescope.pickers').command_history()<CR>]]
    --   return vim.api.nvim_replace_termcodes('<C-u><C-p>', true, false, true)
  end, {
    expr = true,
    noremap = false,
    desc = 'Previous command in cmdline',
  })
  set('c', '<C-/>', function()
    return vim.api.nvim_replace_termcodes('<C-r>*', true, false, true)
  end, {
    expr = true,
    noremap = false,
    desc = 'Insert selection register into search',
  })
  ---///
  --- tab is mapped to buffers, since tab&<c-i> has same func, we
  --- need to map <c-i> to its original func.
  set('n', '<C-i>', '<C-i>', {
    noremap = true,
    expr = false,
  })
  --- provided by rsi.vim
  -- set('i', '<C-e>', '<End>', {
  --   desc = 'Insert mode: move to end of line',
  -- })
  set('n', '<leader>/q', ':qa<cr>', {
    desc = 'Quit vim'
  })


  set(
    'n',
    '<C-S-A-p>',
    cmd([[lua require('legendary').find({ filters = require('legendary.filters').current_mode() })]]),
    {
      desc = 'Open Command Palette',
    }
  )

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

  set({ 'v', 'i' }, '<F1>', cmd('bufdo update'), {
    desc = 'Save all files',
  })
  set('n', '<localleader>w', cmd('update'), {
    desc = 'Save current buffer',
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
  -- set('v', 'p', '"_dP', {
  --   desc = 'Do not yank on visual paste',
  -- })
  -- set('x', 'p', '"_dP', {
  --   desc = 'Do not yank on select paste',
  -- })

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

  set('n', 'H', '^', {
    desc = 'Move to first non-blank character of the line',
  })
  set('n', 'L', '$', {
    desc = 'Move to last non-blank character of the line',
  })

  set('n', 'Y', 'y$', {
    desc = 'Yank to end of line',
  })
  set({ 'v', 'x' }, 'K', ":move '<-2<CR>gv-gv", {
    desc = 'Move selected line / block of text in visual mode up',
  })
  set({ 'v', 'x' }, 'J', ":move '>+1<CR>gv-gv", {
    desc = 'Move selected line / block of text in visual mode down',
  })

  --- buffers
  set('n', '<leader>b]', cmd_modcall('userlib.runtime.buffer', 'next_unsaved_buf()'), {
    desc = 'Next unsaved buffer'
  })
  set('n', '<leader>b[', cmd_modcall('userlib.runtime.buffer', 'prev_unsaved_buf()'), {
    desc = 'Next unsaved buffer'
  })
  set('n', '<leader>bd', [[:e!<CR>]], {
    desc = 'Discard buffer changes'
  })
  set('n', '<leader>bx', function()
    vim.cmd('bdelete')
    vim.schedule(function()
      if #require('userlib.runtime.buffer').list_bufnrs() <= 0 then
        local cur_empty = require('userlib.runtime.buffer').get_current_empty_buffer()
        -- start_dashboard()
        au.do_useraucmd(au.user_autocmds.DoEnterDashboard_User)
        if cur_empty then
          vim.api.nvim_buf_delete(cur_empty, { force = true })
        end
      end
    end)
  end, {
    desc = 'Close buffer and window'
  })

  set('n', '<leader><space><space>', cmd([[normal! m']]), {
    desc = 'Mark jump position',
    noremap = true,
    nowait = true,
  })
  set('n', 'qq', cmd([[:qa]]), {
    desc = 'Quit all',
    noremap = true,
    nowait = true,
  })
  set('c', '<C-q>', ('<C-u>qa<CR>'), {
    desc = 'Make sure <C-q> do not insert weird chars',
    nowait = true,
  })
end

function M.setup()
  setup_basic()
end

return M
