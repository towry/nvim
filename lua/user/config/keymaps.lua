local keymap = require('userlib.runtime.keymap')
-- local libutil = require('userlib.runtime.utils')
local set, cmd, cmd_modcall = keymap.set, keymap.cmdstr, keymap.cmd_modcall

local M = {}
local is_profiling = false

local function setup_basic()
  set('n', 'g?', function()
    local ft = vim.bo.filetype
    if ft == '' then
      vim.notify('No buf local keymap help for ft none', vim.log.levels.INFO)
      return
    end
    local helps = require('userlib.runtime.keymap').get_buf_local_help(ft .. '_')
    if not helps or #helps == 0 then
      vim.notify('No buf local keymap help', vim.log.levels.INFO)
      return
    end
    require('userlib.mini.clue').show_buf_local_help(helps)
  end, {
    desc = 'Show buffer local keys help',
    nowait = true,
    noremap = true,
  })
  set('n', '*', function()
    vim.fn.setreg('/', [[\V\<]] .. vim.fn.escape(vim.fn.expand('<cword>'), [[/\]]) .. [[\>]])
    vim.fn.histadd('/', vim.fn.getreg('/'))
    vim.o.hlsearch = true
  end, {
    nowait = true,
    noremap = true,
  })
  set('n', '<leader>/c', '<cmd>CloseAll<cr>', { nowait = true, noremap = true, desc = 'Close all bufs and windows' })
  set('n', 'q', '<NOP>', {})
  set('n', '<C-q>', 'q', { noremap = true, desc = 'Start record macro' })
  set('n', '<Leader>er', 'gR', { nowait = true, desc = 'Enter visual replace mode' })
  --- a=1
  set('n', '<C-a>a', '<C-a>', { remap = false, nowait = true, silent = true })
  set('n', '<C-a>x', '<C-x>', { remap = false, nowait = true, silent = true })
  --- <C-a> and <C-x> is free to use
  set('i', 'jj', '<ESC>', { silent = true, nowait = true, noremap = true })
  set('i', '<esc>', 'pumvisible() ? "\\<C-e><esc>" : "\\<ESC>"', { silent = true, expr = true, noremap = true })
  set('s', '<esc>', function()
    if vim.snippet then
      vim.snippet.stop()
    end
    return '<ESC>'
  end, {
    desc = 'cancel snippet session',
    expr = true,
    silent = true,
    noremap = true,
  })

  -- Save jumps > 5 lines to the jumplist
  -- Jumps <= 5 respect line wraps
  set('n', 'j', [[(v:count > 5 ? "m'" . v:count . 'j' : 'gj')]], { expr = true })
  set('n', 'k', [[(v:count > 5 ? "m'" . v:count . 'k' : 'gk')]], { expr = true })
  --->>
  set('n', ']b', ':bnext<cr>', { desc = 'Next buffer', silent = false, nowait = true })
  set('n', '[b', ':bpre<cr>', { desc = 'Prev buffer', silent = false, nowait = true })
  set({ 'n', 'i' }, keymap.super('j'), function()
    local buf = require('userlib.runtime.buffer').next_bufnr()
    if buf then
      vim.cmd('b' .. buf)
    end
  end, { desc = 'Next buf', silent = true, nowait = true })
  set({ 'n', 'i' }, keymap.super('k'), function()
    local buf = require('userlib.runtime.buffer').prev_bufnr()
    if buf then
      vim.cmd('b' .. buf)
    end
  end, { desc = 'Prev buf', silent = true, nowait = true })
  set('n', '<c-w>B', function()
    vim.cmd('wincmd b')
    -- check if window is quickfix or terminal
    if vim.fn.win_gettype() == 'quickfix' or vim.bo.buftype == 'terminal' then
      vim.cmd('close')
    end
    vim.cmd('wincmd p')
  end, {
    desc = 'Close bottom window if it is terminal or quickfix',
  })
  set('n', '<leader>rn', function()
    require('userlib.workflow.run-normal-keys')()
  end, {
    noremap = true,
    silent = false,
    desc = 'execute normal keys',
  })
  set('n', '<leader>tt', function()
    if vim.t.CwdLocked then
      vim.cmd('UnlockTcd')
    else
      vim.cmd('LockTcd')
    end
  end, { desc = 'Toggle Tcd lock', nowait = true })
  set('n', '<leader>bt', function()
    if not vim.t.CwdLocked then
      vim.notify('No need to move')
      return
    end
    local bufnr = vim.api.nvim_get_current_buf()
    --- loop tabs from 1, exclude current tab,
    --- if all tabs is locked then open this buffer in new tab.
    for i = 1, vim.fn.tabpagenr('$') do
      if not vim.t[i].CwdLocked then
        vim.cmd(i .. 'tabnext')
        -- open buf in current tab
        vim.api.nvim_win_set_buf(0, bufnr)
        return
      end
    end
    -- open buf in new tab
    vim.cmd.tabnew()
    vim.api.nvim_win_set_buf(0, bufnr)
  end, { desc = 'Temporary open current buffer in a non locked tab' })
  --- use <C-w> in insert to trigger visual select instead of delete
  set('v', '<C-w>', 'B', {})
  --- <left> make <c-o> starts at end of the word before cursor. avoid 'd'
  --- motion create newline.
  set('i', '<C-w>', function()
    -- check current is float
    if vim.api.nvim_win_get_config(0).relative ~= '' then
      return '<C-w>'
    end
    return '<left><C-o>v'
  end, { remap = false, expr = true })
  set(
    'n',
    '<C-w>m',
    '<cmd>wincmd _ <bar> wincmd | <bar> call v:lua.Ty.resize.record()<cr>',
    { nowait = true, noremap = true, desc = 'Max window' }
  )
  set(
    'n',
    '<C-w>=',
    '<cmd>NoFixWin <bar> wincmd = <bar> FixWin <bar> call v:lua.Ty.resize.record()<cr>',
    { nowait = true, noremap = true, desc = 'Equal window' }
  )
  set('v', '<BS>', 'd', { noremap = true })
  set('n', "';", ':lua require("userlib.runtime.buffer").edit_alt_buf()<cr>', {
    silent = true,
    desc = 'Edit alt buf',
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

  set('n', keymap.super(';'), ':<C-u>', {
    expr = false,
    noremap = true,
  })
  set('i', keymap.super(';'), '<esc>:<C-u>', {
    expr = false,
    noremap = true,
    desc = 'Enter cmdline easily',
  })
  --- command line history.
  set('c', keymap.super(';'), function()
    require('userlib.finder').command_history()
  end, {
    expr = false,
    noremap = false,
    desc = 'Previous command in cmdline',
  })
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

  set({ 'n' }, keymap.super('s'), '<cmd>update<cr>', {
    desc = 'Save current buffer',
    silent = false,
    remap = false,
  })
  set({ 'i' }, keymap.super('s'), function()
    vim.cmd.stopinsert()
    vim.schedule(function()
      vim.cmd('update')
    end)
  end, {
    desc = 'Save current buffer',
    silent = true,
  })
  set('n', '<leader>bw', cmd('write'), {
    desc = 'Save current buffer',
    silent = true,
  })
  set('n', '<localleader>bw', cmd('silent! noau update'), {
    desc = 'Update current buffer without autocmd',
    silent = true,
  })
  set('n', '<localleader>bW', cmd('silent! noau wall'), {
    desc = 'Update all buffers without autocmd',
    silent = true,
  })

  set('n', 'H', function()
    local has_folded = vim.fn.foldclosed('.') > -1
    local is_at_first_non_whitespace_char_of_line = (vim.fn.col('.') - 1) == vim.fn.match(vim.fn.getline('.'), '\\S')

    if is_at_first_non_whitespace_char_of_line and not has_folded then
      return 'za'
    end
    if vim.fn.foldclosed('.') == -1 then
      return '^'
    end
  end, {
    desc = 'Move to first non-blank character of the line',
    expr = true,
    remap = false,
  })
  set('n', 'L', function()
    if vim.fn.foldclosed('.') > -1 then
      return 'zo'
    else
      return '$'
    end
  end, {
    expr = true,
    remap = false,
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

  for i = 1, 9 do
    set('n', '<space>' .. i, cmd(i .. 'tabnext'), {
      desc = 'Go to tab ' .. i,
    })
    --- use option key to navigate tab quickly.
    --- cmd key is used by the mux program.
    set({ 'n', 't' }, '<M-' .. i .. '>', cmd(i .. 'tabnext'), {
      desc = 'Go to tab ' .. i,
    })
  end
  set({ 'i', 'n', 't' }, '<M-[>', cmd('tabp'), { desc = 'Tab pre' })
  set({ 'i', 'n', 't' }, '<M-]>', cmd('tabn'), { desc = 'Tab next' })
  set('n', '<leader>tn', cmd('tabnew'), {
    desc = 'New tab',
  })
  -- map alt+number to navigate to window by ${number} . wincmd w<cr>
  for i = 1, 9 do
    set('n', '<leader>w' .. i, cmd(i .. 'wincmd w'), {
      desc = 'which_key_ignore',
    })
  end
  set('n', '<leader>wp', cmd('wincmd p'), {
    desc = 'Go to previous window',
  })
  set({ 'n', 't', 'i' }, '<M-w>', cmd('wincmd p'), {
    desc = 'Go to previous window',
  })
  set({ 'n', 't', 'i' }, '<M-t>', cmd('tabnext #'), {
    desc = 'Go to last accessed tab',
  })

  set('c', '<C-q>', '<C-u>qa<CR>', {
    desc = 'Make sure <C-q> do not insert weird chars',
    nowait = true,
  })

  set('n', '<leader>tw', cmd('pclose'), {
    desc = 'Close any preview windows',
    nowait = true,
  })

  -- works with quickfix
  set('n', '<leader>qq', '<cmd>lua require("userlib.runtime.qf").toggle_qf()<cr>', { desc = 'Toggle quickfix' })
  set('n', '<leader>ql', '<cmd>lua require("userlib.runtime.qf").toggle_loc()<cr>', { desc = 'Toggle loclist' })
  set('n', '<leader>qs', '<cmd>lua require("userlib.finder").quickfix_stack()<cr>', { desc = 'Quickfix stack' })
  set('n', '[q', ':cprev<cr>', {
    desc = 'Jump to previous quickfix item',
  })
  set('n', ']q', ':cnext<cr>', {
    desc = 'Jump to next quickfix item',
  })
  set('n', '[l', ':lprev<cr>', {
    desc = 'Jump to previous loclist item',
  })
  set('n', ']l', ':lnext<cr>', {
    desc = 'Jump to next loclist item',
  })
  set('n', '[qf', function()
    pcall(function()
      vim.cmd('1000cabove')
    end)
    local ok = pcall(function()
      vim.cmd('cprev')
    end)
    if not ok then
      vim.notify('No more items', vim.log.levels.ERROR)
    end
  end, {
    desc = "Jump to prev file's first error item in quickfix",
  })
  set('n', ']qf', function()
    pcall(function()
      vim.cmd('1000cbelow')
    end)
    local ok = pcall(function()
      vim.cmd('cnext')
    end)
    if not ok then
      vim.notify('No more items', vim.log.levels.ERROR)
    end
  end, {
    desc = "Jump to next file's first error item in quickfix",
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
    if tip_is_loading then
      return
    end
    local job = require('plenary.job')
    vim.notify('loading tip...')
    job
      :new({
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
      })
      :start()
  end, {
    desc = 'Get a random tip from vtip.43z.one',
  })

  set('n', '<leader>rzr', function()
    -- https://github.com/echasnovski/mini.visits/blob/7f2836d9f3957843e0d00762a3f3bb47cf88b92e/lua/mini/visits.lua#L1407
    local ok, res = pcall(vim.fn.input, { prompt = '[zellij] Command to run: ', cancelreturn = false })
    if not ok or res == false then
      return
    end
    vim.cmd(string.format('OverDispatch! zellij run -d down -- %s', res))
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

  set('n', '<leader>zr', function()
    vim.cmd.resize()
    vim.cmd('OnDarkMode')
  end, {
    desc = 'Resize after window size changed',
    silent = false,
  })
  set('n', '<leader>z<space>', ':ToggleDark<CR>', {
    desc = 'Toggle dark mode',
    noremap = true,
    silent = true,
  })

  set('n', '<localleader>M', ':TryMake', {
    desc = 'Run make',
    silent = false,
  })
  set('n', '<localleader>m', ':OverMake', {
    desc = 'Run makeprg',
    silent = false,
  })

  set('n', '<A-q>', function()
    local current_win_is_qf = vim.bo.filetype == 'qf'
    if current_win_is_qf then
      vim.cmd('wincmd p')
    else
      -- focus on qf window
      vim.cmd('copen')
    end
  end, {
    desc = 'Switch between quickfix window and previous window',
  })

  set('n', '<leader>rl', function()
    local line = 'lua ' .. vim.trim(vim.api.nvim_get_current_line())
    vim.print('RL: ' .. line)
    vim.api.nvim_command(line)
    -- vim.api.nvim_input('<Down>')
  end, {
    desc = 'Execute current line as lua command',
  })
  set('n', '<leader>np', function()
    local reg = vim.v.register or '"'
    vim.cmd(':put ' .. reg)
    vim.cmd([[normal! `[v`]=]])
  end, {
    expr = false,
    noremap = true,
    silent = false,
    desc = 'Paste in next line and format',
  })
  set('n', '<leader>nP', function()
    local reg = vim.v.register or '"'
    vim.cmd(':put! ' .. reg)
    vim.cmd([[normal! `[v`]=]])
  end, {
    expr = false,
    noremap = true,
    silent = false,
    desc = 'Paste in above line and format',
  })
  set('n', '<leader>nv', '`[v`]', {
    expr = false,
    noremap = true,
    silent = false,
    desc = 'Visual select pasted content',
  })

  if vim.cfg.runtime__starts_as_gittool then
    set('v', 'dp', [[:<C-u>'<,'>diffput<cr>]], {
      desc = 'Diffput in visual',
      silent = true,
    })
    set('v', 'do', [[:<C-u>'<,'>diffget<cr>]], {
      desc = 'Diffget in visual',
      silent = true,
    })
    set('n', '<localleader>w', ':w|cq', { desc = '[Git mergetool] Prepare write and exit safe' })
    set('n', '<localleader>c', ':cq 1', { desc = '[Git mergetool] Prepare to abort' })
  end

  --- wait: https://github.com/neovim/neovim/issues/25714
  --- wait: https://github.com/neovim/neovim/pull/27339
  local keys = {
    ['cr'] = vim.api.nvim_replace_termcodes('<CR>', true, true, false),
    -- close pum after completion
    ['ctrl-y'] = vim.api.nvim_replace_termcodes('<C-y>', true, true, false),
    ['ctrl-j'] = vim.api.nvim_replace_termcodes('<C-j>', true, true, false),
    ['ctrl-y_cr'] = vim.api.nvim_replace_termcodes('<C-y><CR>', true, true, false),
    ['space'] = vim.api.nvim_replace_termcodes('<Space>', true, true, false),
    ['ctrl-z'] = vim.api.nvim_replace_termcodes('<C-z>', true, true, false),
    ['bs-ctrl-z'] = vim.api.nvim_replace_termcodes('<C-h><C-z>', true, true, false),
  }
  ---- wildmode
  if vim.tbl_contains({ 'coq', 'native' }, vim.cfg.edit__cmp_provider) then
    -- set({ 'c' }, '<', '<', { noremap = true, silent = false })
    set({ 'c' }, [[<Tab>]], function()
      if vim.fn.pumvisible() ~= 0 then
        return '<C-n>'
      else
        return '<C-z>'
      end
    end, { expr = true, silent = false, noremap = true })
    --- back a whitespace and then trigger completion.
    set('c', [[<C-h>]], function()
      if vim.fn.pumvisible() ~= 0 then
        return '<C-n>'
      end
      return keys['bs-ctrl-z']
    end, { expr = true, silent = false, noremap = true })
    ---- native cmp keys
    -- Move inside completion list with <TAB>
    set({ 'i', 's' }, [[<Tab>]], function()
      if vim.fn.pumvisible() ~= 0 then
        return '<C-n>'
      elseif vim.snippet.active({ direction = 1 }) then
        --- must use schedule becase edit must occures in next loop.
        vim.schedule(function()
          vim.snippet.jump(1)
        end)
      else
        if package.loaded['neotab'] then
          -- final fallback
          return [[<Plug>(neotab-out)]]
        else
          return '<Tab>'
        end
      end
    end, { expr = true, silent = false })

    set({ 'i', 's' }, [[<CR>]], function()
      if vim.fn.pumvisible() ~= 0 then
        local item_selected = vim.fn.complete_info()['selected'] ~= -1
        return item_selected and keys['ctrl-y'] or keys['ctrl-y_cr']
      end
      return keys['cr']
    end, { expr = true, silent = true, noremap = true })

    set({ 'i', 's' }, [[<S-Tab>]], function()
      if vim.fn.pumvisible() ~= 0 then
        return '<C-p>'
      elseif vim.snippet.active({ direction = -1 }) then
        vim.schedule(function()
          vim.snippet.jump(-1)
        end)
      else
        return '<S-Tab>'
      end
    end, { expr = true, silent = false })

    set({ 'i' }, '<C-j>', function()
      local trigger_ai = function()
        -- trigger ai
        if vim.b._copilot then
          vim.fn['copilot#Suggest']()
        elseif vim.fn.exists('*codeium#Complete') == 1 then
          vim.fn['codeium#Complete']()
        end
      end

      -- accept ai or completion selection.
      if vim.fn.pumvisible() ~= 0 then
        local item_selected = vim.fn.complete_info()['selected'] ~= -1
        if item_selected then
          return keys['ctrl-j']
        end
      end

      if Ty.has_ai_suggestions() and Ty.has_ai_suggestion_text() then
        if vim.b._copilot then
          vim.fn.feedkeys(vim.fn['copilot#Accept'](), 'i')
        elseif vim.b._codeium_completions then
          vim.fn.feedkeys(vim.fn['codeium#Accept'](), 'i')
        end
      else
        trigger_ai()
      end
    end, {
      silent = false,
      expr = true,
      noremap = true,
      desc = 'Complete AI or nvim completion',
    })
  end
end

function M.setup()
  setup_basic()
end

return M
