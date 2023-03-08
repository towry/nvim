local M = {}

M.open_window_hydra = function(is_manually)
  local Hydra = require('hydra')
  local cmd = require('hydra.keymap-util').cmd
  local pcmd = require('hydra.keymap-util').pcmd

  local hint = [[
  Move:  _h_: ←    _j_: ↓    _k_: ↑    _l_: →
  Shift: _H_: ←    _J_: ↓    _K_: ↑    _L_: →
  Split: _x_: horizontal _v_: vertical
  Close: _c_: close _q_: close
  Other: _w_: next _z_: maximize _o_: remain only
  ]]
  local instance = Hydra({
    name = "Window Operations",
    config = {
      color = 'pink',
      invoike_on_body = true,
      hint = {
        border = Ty.Config.ui.float.border,
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

      { 'H', '<cmd>lua Ty.Func.buffer.swap_buffer_to_window("left")<cr>', { exit = true } },
      { 'J', '<cmd>lua Ty.Func.buffer.swap_buffer_to_window("down")<cr>', { exit = true } },
      { 'K', '<cmd>lua Ty.Func.buffer.swap_buffer_to_window("up")<cr>', { exit = true } },
      { 'L', '<cmd>lua Ty.Func.buffer.swap_buffer_to_window("right")<cr>', { exit = true } },

      { '=', '<C-w>=', { desc = 'equalize', exit = true } },

      { 'x', pcmd('split', 'E36'), { nowait = true, exit = true } },
      { '<C-s>', pcmd('split', 'E36'), { desc = false, nowait = true, exit = true } },
      { 'v', pcmd('vsplit', 'E36'), { nowait = true, exit = true } },
      { '<C-v>', pcmd('vsplit', 'E36'), { desc = false, nowait = true } },

      { 'w', '<C-w>w', { exit = true, desc = false } },
      { '<C-w>', '<C-w>w', { exit = true, desc = false } },

      { 'z', cmd 'WindowsMaximaze', { exit = true, desc = 'maximize' } },
      { '<C-z>', cmd 'WindowsMaximaze', { exit = true, desc = false } },

      { 'o', '<C-w>o', { exit = true, desc = 'remain only' } },
      { '<C-o>', '<C-w>o', { exit = true, desc = false } },

      { 'c', pcmd('close', 'E444') },
      { 'q', pcmd('close', 'E444'), { desc = 'close window' } },
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
