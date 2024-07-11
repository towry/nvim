-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- http://www.lazyvim.org/configuration/plugins#%EF%B8%8F-adding--disabling-plugin-keymaps

--- lazynvim's default keymaps can be deleted with del.
local del = vim.keymap.del
local set = vim.keymap.set
local Insert = 'i'
local Visual = 'v'
local Command = 'c'
local OperatorPending = 'o'
local Normal = 'n'

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
}

-- [ ] choose window to close

do
  for _, v in ipairs(maps) do
    set(v[1], v[2], v[3], v[4])
  end
end
