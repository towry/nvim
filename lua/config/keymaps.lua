-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- http://www.lazyvim.org/configuration/plugins#%EF%B8%8F-adding--disabling-plugin-keymaps

--- lazynvim's default keymaps can be deleted with del.
local del = vim.keymap.del
local set = vim.keymap.set
local Insert = 'i'
local Visual = 'v'
-- local Command = 'c'
-- local OperatorPending = 'o'
local Normal = 'n'

del('n', '<S-h>')
del('n', '<S-l>')

local maps = {
  {
    Insert,
    'jj',
    '<ESC>',
    {
      desc = 'Leave insert with jj',
      silent = true,
      nowait = true,
      noremap = true,
    },
  },
  {
    Visual,
    '<C-w>',
    'B',
    {
      desc = '<C-w> in insert starts selection mode and this continue select in visual mode',
    },
  },
  {
    Insert,
    '<C-w>',
    function()
      -- check current is float
      if vim.api.nvim_win_get_config(0).relative ~= '' then
        return '<C-w>'
      end
      return '<left><C-o>v'
    end,
    {
      desc = 'Enhance <c-w> in insert',
      remap = false,
      expr = true,
    },
  },
  {
    Normal,
    '<C-c><C-k>',
    function()
      local tabs_count = vim.fn.tabpagenr('$')
      if tabs_count <= 1 then
        vim.cmd('silent! hide | echo "hide current window"')
        return
      end
      --- get current tab's window count
      local win_count = require('v').tab_win_count()
      if win_count <= 1 then
        local choice = vim.fn.confirm('Close last window in tab?', '&Yes\n&No', 2)
        if choice == 2 then
          return
        end
        return
      end
      vim.cmd('silent! hide | echo "hide current window"')
    end,
    {
      desc = 'Kill current window',
    },
  },
  {
    Normal,
    '<C-c><C-d>',
    function()
      if vim.fn.exists('&winfixbuf') == 1 and vim.api.nvim_get_option_value('winfixbuf', { win = 0 }) then
        vim.cmd('hide')
        return
      end

      LazyVim.ui.bufremove()
    end,
    {
      desc = 'Kill current buffer',
    },
  },
  {
    Normal,
    '<C-c><C-c>',
    function()
      if vim.fn.exists('&winfixbuf') == 1 and vim.api.nvim_get_option_value('winfixbuf', { win = 0 }) then
        vim.cmd('hide')
        return
      end
      if vim.api.nvim_win_get_config(vim.api.nvim_get_current_win()).relative ~= '' then
        --- float window
        vim.cmd('close')
        return
      end
      vim.cmd([[echo "Unshow buffer " .. bufnr("%")]])
      LazyVim.ui.bufremove(0)
    end,
    {
      desc = 'Unshow current buffer',
    },
  },
}

-- [ ] choose window to close

do
  for _, v in ipairs(maps) do
    set(v[1], v[2], v[3], v[4])
  end
end


--------------------------------

--- setup keymap on terminal
vim.g.set_terminal_keymaps = vim.schedule_wrap(function(bufnr)
  local nvim_buf_set_keymap = vim.keymap.set
  local buffer = bufnr or vim.api.nvim_get_current_buf()
  local opts = { noremap = true, buffer = buffer, nowait = true, silent = true }

  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end

  --- prevent <C-z> behavior in all terminals in neovim
  nvim_buf_set_keymap('t', '<C-z>', '<NOP>', opts)

  -- do not bind below keys in fzf-lua terminal window.
  if vim.tbl_contains({ 'yazi', 'fzf' }, vim.bo.filetype) then
    return
  end

  nvim_buf_set_keymap('t', '<esc><esc>', function()
    vim.cmd.stopinsert()
  end, opts)
  nvim_buf_set_keymap({ 'n', 't' }, '<F2>', function()
    if not vim.b.osc7_dir then
      return
    end
    vim.cmd('stopinsert')

    vim.schedule(function()
      local choice = vim.fn.confirm('Cd into: ' .. vim.b.osc7_dir .. ' ?', '&Yes\n&No', 2)
      if choice == 1 then
        vim.cmd('Cdin ' .. vim.b.osc7_dir)
        return
      end
      vim.cmd.startinsert()
    end)
  end, opts)

  nvim_buf_set_keymap('n', 'q', [[:startinsert<cr>]], opts)
  -- nvim_buf_set_keymap('t', '<ESC>', [[<C-\><C-n>]], opts)
  --- switch windows
  nvim_buf_set_keymap('t', '<C-\\><C-h>', [[<C-\><C-n><C-W>h]], opts)
  nvim_buf_set_keymap('t', '<C-\\><C-j>', [[<C-\><C-n><C-W>j]], opts)
  nvim_buf_set_keymap('t', '<C-\\><C-k>', [[<C-\><C-n><C-W>k]], opts)
  nvim_buf_set_keymap('t', '<C-\\><C-l>', [[<C-\><C-n><C-W>l]], opts)

  --- resize
  -- nvim_buf_set_keymap('t', '<A-h>', [[<C-\><C-n><A-h>]], opts)
  -- nvim_buf_set_keymap('t', '<A-j>', [[<C-\><C-n><A-j>]], opts)
  -- nvim_buf_set_keymap('t', '<A-k>', [[<C-\><C-n><A-k>]], opts)
  -- nvim_buf_set_keymap('t', '<A-l>', [[<C-\><C-n><A-l>]], opts)
end)
