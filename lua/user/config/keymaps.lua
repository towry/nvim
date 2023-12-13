local keymap = require('userlib.runtime.keymap')
local utils = require('userlib.runtime.utils')
local set, cmd, cmd_modcall = keymap.set, keymap.cmdstr, keymap.cmd_modcall

local M = {}
local is_profiling = false

--- only do this in tmux.
local xk = utils.utf8keys({
  [ [[<D-s>]] ] = 0xAA,
  [ [[<C-'>]] ] = 0xAD,
  [ [[<C-;>]] ] = 0xAB,
  [ [[<C-i>]] ] = 0xAC,
}, true)

local function setup_basic()
  --->>
  set('n', '<leader>rn', function() require('userlib.workflow.run-normal-keys')() end, {
    noremap = true,
    silent = false,
    desc = 'execute normal keys',
  })
  set('n', '<leader>rs', ':lua require("userlib.workflow.run-shell-cmd")({ silent = true })<cr>', {
    silent = true,
    noremap = true,
    desc = 'run shell command in silent',
  })
  set('n', '<leader>rS', ':lua require("userlib.workflow.run-shell-cmd")({ silent = false })<cr>', {
    silent = true,
    noremap = true,
    desc = 'run shell command, no silent',
  })

  --- quickly go into cmd
  set('n', '«', ':<C-u>', {
    expr = false,
    noremap = true,
  })
  set('i', '«', '<esc>:<C-u>', {
    expr = false,
    noremap = true,
  })
  set('n', xk([[<C-;>]]), ':<C-u>', {
    expr = false,
    noremap = true,
  })
  set('i', '<C-;>', '<esc>:<C-u>', {
    expr = false,
    noremap = true,
    desc = 'Enter cmdline easily',
  })
  --- command line history.
  set('c', xk([[<C-;>]]), function()
    return [[lua require('userlib.telescope.pickers').command_history()<CR>]]
    --   return vim.api.nvim_replace_termcodes('<C-u><C-p>', true, false, true)
  end, {
    expr = true,
    noremap = false,
    desc = 'Previous command in cmdline',
  })
  ---///
  --- tab is mapped to buffers, since tab&<c-i> has same func, we
  --- need to map <c-i> to its original func.
  set('n', xk([[<C-i>]]), '<C-i>', {
    noremap = true,
    expr = false,
  })
  --- <C-i> that works in zellij.
  set('n', '¬', '<C-i>', {
    noremap = true,
    expr = false,
    nowait = true,
  })
  --- provided by rsi.vim
  -- set('i', '<C-e>', '<End>', {
  --   desc = 'Insert mode: move to end of line',
  -- })
  set('n', '<leader>/q', ':qa<cr>', {
    desc = 'Quit vim',
  })

  set(
    'n',
    '<C-S-A-p>',
    cmd([[lua require('legendary').find({ filters = require('legendary.filters').current_mode() })]]),
    {
      desc = 'Open Command Palette',
    }
  )

  set('n', '<ESC>', function()
    vim.cmd('nohl')
    if vim.g.escape_cmd ~= nil and vim.g.escape_cmd ~= '' then
      local escape_cmd = vim.g.escape_cmd
      vim.schedule(function()
        vim.cmd(escape_cmd)
      end)
      vim.g.escape_cmd = nil
    end
    return '<esc>'
  end, {
    desc = 'Clear search highlight',
    silent = true,
    noremap = true,
    expr = true,
  })
  set('v', '<', '<gv', {
    desc = 'Keep visual mode indenting, left',
  })
  set('v', '>', '>gv', {
    desc = 'Keep visual mode indenting, right',
  })
  set('v', '`', 'u', {
    desc = 'Case change in visual mode',
  })

  -- this is what <D-s> output in zellij.
  set({ 'n', 'i' }, 'ª', '<ESC>:silent! update<cr>', {
    desc = 'Save buffer',
    silent = true,
  })
  set({ 'n', 'i' }, xk([[<D-s>]]), '<ESC>:silent! update<cr>', {
    desc = 'Save current buffer',
    silent = true,
  })
  set('n', '<leader>bw', cmd('silent! update'), {
    desc = 'Save current buffer',
    silent = true,
  })

  -- yanks
  set({ 'n', 'v' }, 'd', function()
    -- NOTE: add different char for different buffer, for example, in oil, use o|O
    if vim.v.register == 'd' or vim.v.register == 'D' then return '"' .. vim.v.register .. 'd' end
    return '"dd'
  end, {
    silent = true,
    desc = 'Delete char and yank to register d',
    noremap = true,
    expr = true,
  })
  set({ 'n', 'v' }, 'D', '"dD', {
    desc = 'Delete to end of line and yank to register d',
    silent = true,
    expr = true,
    noremap = true,
  })
  --- do not cut on normal mode.
  set({ 'n', 'v' }, 'x', function()
    if vim.v.register == 'x' or vim.v.register == 'X' then return '"' .. vim.v.register .. 'x' end
    return '"xx'
  end, {
    expr = true,
    silent = true,
    noremap = true,
    desc = 'Cut chars and do not yank to register',
  })
  set({ 'n', 'v' }, 'X', function()
    if vim.v.register == 'x' or vim.v.register == 'X' then return '"' .. vim.v.register .. 'X' end
    return '"xX'
  end, {
    expr = true,
    silent = true,
    noremap = true,
    desc = 'Cut chars and do not yank to register',
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
    desc = 'Next unsaved buffer',
  })
  set('n', '<leader>b[', cmd_modcall('userlib.runtime.buffer', 'prev_unsaved_buf()'), {
    desc = 'Next unsaved buffer',
  })
  set('n', '<leader>be', [[:earlier 1f<cr>]], {
    desc = 'Most earlier buffer changes',
  })
  set('n', '<leader>bd', function()
    -- TODO: select next buffer.
    vim.cmd('bdelete')
  end, {
    desc = 'Close buffer and window',
  })

  for i = 1, 9 do
    set('n', '<space>' .. i, cmd(i .. 'tabnext'), {
      desc = 'Go to tab ' .. i,
    })
  end
  set('n', '<leader>tn', cmd('tabnew'), {
    desc = 'New tab',
  })
  -- map alt+number to navigate to window by ${number} . wincmd w<cr>
  for i = 1, 9 do
    set('n', '<M-' .. i .. '>', cmd(i .. 'wincmd w'), {
      desc = 'which_key_ignore',
    })
  end
  set('n', '<M-`>', cmd('wincmd p'), {
    desc = 'which_key_ignore',
  })

  set('n', 'qq', cmd([[:qa]]), {
    desc = 'Quit all',
    noremap = true,
    nowait = true,
  })
  set('c', '<C-q>', '<C-u>qa<CR>', {
    desc = 'Make sure <C-q> do not insert weird chars',
    nowait = true,
  })

  set('n', '<leader>tw', cmd('pclose'), {
    desc = 'Close any preview windows',
    nowait = true
  })

  -- works with quickfix
  set('n', '[q', ':cprev<cr>', {
    desc = 'Jump to previous quickfix item',
  })
  set('n', ']q', ':cnext<cr>', {
    desc = 'Jump to next quickfix item',
  })

  set('n', '<leader>tp', function()
    if is_profiling then
      is_profiling = false
      Ty.StopProfile()
      vim.notify('profile stopped', vim.log.levels.INFO)
      return
    end
    is_profiling = true
    Ty.StartProfile('profile.log', { flame = true })
  end, {
    desc = 'Toggle profile',
  })

  local tip_is_loading = false
  set('n', '<leader>/t', function()
    if tip_is_loading then return end
    local job = require 'plenary.job'
    vim.notify('loading tip...')
    job:new({
      command = 'curl',
      args = { 'https://vtip.43z.one' },
      on_exit = function(j, exit_code)
        tip_is_loading = false
        local res = table.concat(j:result())
        if exit_code ~= 0 then
          res = 'Error fetching tip: ' .. res
        end
        print(res)
      end,
    }):start()
  end, {
    desc = 'Get a random tip from vtip.43z.one'
  })

  set('n', '<leader>rzr', function()
    -- https://github.com/echasnovski/mini.visits/blob/7f2836d9f3957843e0d00762a3f3bb47cf88b92e/lua/mini/visits.lua#L1407
    local ok, res = pcall(vim.fn.input, { prompt = '[zellij] Command to run: ', cancelreturn = false })
    if not ok or res == false then return end
    vim.cmd(string.format('Dispatch! zellij run -d down -- %s', res))
  end, {
    desc = 'zellij run',
  })

  --- function to toggle option and echo the new option and option value.
  local function toggle_option(option_name)
    return function()
      vim.cmd(string.format('set %s!', option_name))
      local option_value = vim.o[option_name]
      vim.notify(string.format('[option!] %s: %s', option_name, option_value))
    end
  end
  --- toggle options
  set('n', '<leader>tow', toggle_option('wrap'), {
    desc = 'Toggle wrap',
  })
  -- number
  set('n', '<leader>tor', toggle_option('relativenumber'), {
    desc = 'Toggle number',
  })
  set('n', '<leader>ton', toggle_option('number'), {
    desc = 'Toggle number',
  })
end

function M.setup() setup_basic() end

return M
