local M = {}

local function get_window_bufnr(winid)
  return vim.api.nvim_win_call(winid, function()
    return vim.fn.bufnr('%')
  end)
end
local function change_window_bufnr(winid, bufnr)
  vim.api.nvim_win_call(winid, function()
    vim.cmd(string.format('buffer %d', bufnr))
  end)
end

M.open_window_hydra = function(is_manually)
  local Hydra = require('hydra')
  -- local cmd = require('hydra.keymap-util').cmd
  local pcmd = require('hydra.keymap-util').pcmd

  local hint = [[
  focus:   _h_: ←    _j_: ↓    _k_: ↑    _l_: →
  Rerange: _H_: ←    _J_: ↓    _K_: ↑    _L_: →    _x_: swap
  Split:   _s_: Horizontal _v_: Vertical _T_: Move-to-tab
  Close:   _c_: Close _q_: Close
  Auto:    _a_: Auto Size   _m_: Maximize  _f_: No auto size
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
      { 'h',     '<C-w>h' },
      { 'j',     '<C-w>j' },
      { 'k',     pcmd('wincmd k', 'E11', 'close') },
      { 'l',     '<C-w>l' },
      { 'a',     '<cmd>WindowsEnableAutowidth<cr>',  { exit = true, nowait = true, desc = 'Toggle auto size' } },
      { 'm',     '<cmd>WindowsMaximize<cr>',         { exit = true, nowait = true, desc = 'maximize window' } },
      { 'f',     '<cmd>WindowsDisableAutowidth<cr>', { exit = true, nowait = true, desc = 'Disable auto size' } },
      { 'H',     '<C-w>H',                           { exit = true } },
      { 'J',     '<C-w>J',                           { exit = true } },
      { 'K',     '<C-w>K',                           { exit = true } },
      { 'L',     '<C-w>L',                           { exit = true } },
      { 'T',     '<C-w>T',                           { exit = true } },
      { '=',     '<C-w>=',                           { desc = 'equalize', exit = true } },
      { 's',     pcmd('split', 'E36'),               { nowait = true, exit = true } },
      { '<C-s>', pcmd('split', 'E36'),               { desc = false, nowait = true, exit = true } },
      { 'v',     pcmd('vsplit', 'E36'),              { nowait = true, exit = true } },
      { '<C-v>', pcmd('vsplit', 'E36'),              { desc = false, nowait = true } },
      { 'w',     '<C-w>w',                           { exit = true, desc = false } },
      { '<C-w>', '<C-w>w',                           { exit = true, desc = false } },
      { 'o',     '<C-w>o',                           { exit = true, desc = 'remain only' } },
      { '<C-o>', '<C-w>o',                           { exit = true, desc = false } },
      { 'p',     '<C-w><C-p>',                       { exit = true, nowait = true } },
      { 'x', function()
        local cur_win = vim.api.nvim_get_current_win()
        if vim.fn.winnr('$') <= 2 then
          vim.cmd('wincmd x')
          return
        end
        vim.schedule(function()
          local ok, winpick = pcall(require, 'window-picker')
          if not ok then
            vim.cmd('wincmd x')
            return
          else
            local picked = winpick.pick_window({
              autoselect_one = false,
              include_current_win = false,
              hint = 'floating-big-letter',
            })
            if not picked then return end
            local current_bufnr = get_window_bufnr(cur_win)
            local target_bufnr = get_window_bufnr(picked)
            change_window_bufnr(picked, current_bufnr)
            -- use wincmd to focus picked window.
            change_window_bufnr(cur_win, target_bufnr)
            vim.cmd(string.format('%dwincmd w', vim.fn.win_id2win(picked)))
            -- go back, so we can use quickly switch between those two window.
            vim.cmd('wincmd p')
          end
        end)
      end, { exit = true, nowait = true, desc = 'swap window' } },
      { 'c',     pcmd('close', 'E444'), { exit = true, nowait = true } },
      { 'q',     pcmd('close', 'E444'), { desc = 'close window', exit = true } },
      { '<C-c>', pcmd('close', 'E444'), { desc = false } },
      { '<C-q>', pcmd('close', 'E444'), { desc = false } },
      { '<Esc>', nil,                   { exit = true, desc = false } },
    }
  })

  if is_manually then
    instance:activate()
  end
end


return M
