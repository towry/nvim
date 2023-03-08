local M = {}

M.open_window_hydra = function(is_manually)
  local Hydra = require('hydra')
  local cmd = require('hydra.keymap-util').cmd
  local pcmd = require('hydra.keymap-util').pcmd

  local hint = [[
      Focus        Move           Split
 -----------------------------------------------------
       _k_           _K_         _s_: horizontally
   _h_      _l_    _H_       _L_   _v_: vertically
       _j_           _J_
     focus         window       _z_: maximize
   _q_, _c_: close              _o_: remain only
]]

  local instance = Hydra({
    name = "Window Operations",
    config = {
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
      { 'h',     '<C-w>h' },
      { 'j',     '<C-w>j' },
      { 'k',     pcmd('wincmd k', 'E11', 'close') },
      { 'l',     '<C-w>l' },
      { 'H',     cmd 'WinShift left' },
      { 'J',     cmd 'WinShift down' },
      { 'K',     cmd 'WinShift up' },
      { 'L',     cmd 'WinShift right' },

      { '=',     '<C-w>=',                        { desc = 'equalize', exit = true } },

      { 's',     pcmd('split', 'E36'),            { nowait = true, exit = true } },
      { '<C-s>', pcmd('split', 'E36'),            { desc = false, nowait = true, exit = true } },
      { 'v',     pcmd('vsplit', 'E36'),           { nowait = true, exit = true } },
      { '<C-v>', pcmd('vsplit', 'E36'),           { desc = false, nowait = true } },

      { 'w',     '<C-w>w',                        { exit = true, desc = false } },
      { '<C-w>', '<C-w>w',                        { exit = true, desc = false } },

      { 'z',     cmd 'WindowsMaximaze',           { exit = true, desc = 'maximize' } },
      { '<C-z>', cmd 'WindowsMaximaze',           { exit = true, desc = false } },

      { 'o',     '<C-w>o',                        { exit = true, desc = 'remain only' } },
      { '<C-o>', '<C-w>o',                        { exit = true, desc = false } },

      { 'c',     pcmd('close', 'E444') },
      { 'q',     pcmd('close', 'E444'),           { desc = 'close window' } },
      { '<C-c>', pcmd('close', 'E444'),           { desc = false } },
      { '<C-q>', pcmd('close', 'E444'),           { desc = false } },

      { '<Esc>', nil,                             { exit = true, desc = false } },
    }
  })

  if is_manually then
    instance:activate()
  end
end


return M
