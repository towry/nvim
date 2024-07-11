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
