local M = {}

M.open_window_hydra = function(is_manually)
  local Hydra = require('hydra')
  -- local cmd = require('hydra.keymap-util').cmd
  local pcmd = require('hydra.keymap-util').pcmd

  local hint = [[
  focus:   _h_: ←    _j_: ↓    _k_: ↑    _l_: →
  Rerange: _H_: ←    _J_: ↓    _K_: ↑    _L_: →
  Split:   _x_: Horizontal _v_: Vertical
  Close:   _c_: Close _q_: Close
  Auto:    _a_: Toggle Auto Size
  Other:   _w_: Next  _o_: Remain only|Maximize
           _p_: Last
  ]]
  local instance = Hydra({
    name = "Window Operations",
    config = {
      color = 'pink',
      invoike_on_body = true,
      hint = {
        border = vim.cfg.ui__float_border,
        offset = -1,
      }
    },
    hint = hint,
    mode = is_manually and nil or { "n" },
    body = is_manually and nil or "<C-w>",
    heads = {
      { 'h', '<C-w>h' },
      { 'j', '<C-w>j' },
      { 'k', pcmd('wincmd k', 'E11', 'close') },
      { 'l', '<C-w>l' },
      { 'a', '<cmd>WindowsToggleAutowidth<cr>', { exit = true, nowait = true, desc = 'Toggle auto size' } },
      { 'H', '<C-w>H', { exit = true } },
      { 'J', '<C-w>J', { exit = true } },
      { 'K', '<C-w>K', { exit = true } },
      { 'L', '<C-w>L', { exit = true } },
      { '=', '<C-w>=', { desc = 'equalize', exit = true } },
      { 'x', pcmd('split', 'E36'), { nowait = true, exit = true } },
      { '<C-s>', pcmd('split', 'E36'), { desc = false, nowait = true, exit = true } },
      { 'v', pcmd('vsplit', 'E36'), { nowait = true, exit = true } },
      { '<C-v>', pcmd('vsplit', 'E36'), { desc = false, nowait = true } },
      { 'w', '<C-w>w', { exit = true, desc = false } },
      { '<C-w>', '<C-w>w', { exit = true, desc = false } },
      { 'o', '<C-w>o', { exit = true, desc = 'remain only' } },
      { '<C-o>', '<C-w>o', { exit = true, desc = false } },
      { 'p', '<C-w><C-p>', { exit = true, nowait = true } },
      { 'c', pcmd('close', 'E444'), { exit = true, nowait = true } },
      { 'q', pcmd('close', 'E444'), { desc = 'close window', exit = true } },
      { '<C-c>', pcmd('close', 'E444'), { desc = false } },
      { '<C-q>', pcmd('close', 'E444'), { desc = false } },
      { '<Esc>', nil, { exit = true, desc = false } },
    }
  })

  if is_manually then
    instance:activate()
  end
end


return M
