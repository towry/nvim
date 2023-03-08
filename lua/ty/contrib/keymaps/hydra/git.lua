local M = {}

M.open_git_conflict_hydra = function()
  local hint = [[
  Git Conflict
  _b_: "Choose both"    _n_: "Move to next conflict →"
  _o_: "Choose ours"    _p_: "Move to prev conflict ←"
  _t_: "Choose theirs"  _q_: "Exit"
  ]]
  local Hydra = require('hydra')
  Hydra({
    name = 'Git conflict',
    color = 'blue',
    hint = hint,
    config = {
      color = 'blue',
      hint = {
        border = Ty.Config.ui.float.border,
      }
    },
    heads = {
      { 'b', '<cmd>GitConflictChooseBoth<CR>', { desc = 'choose both' } },
      { 'n', '<cmd>GitConflictNextConflict<CR>', { desc = 'move to next conflict', exit = false } },
      { 'o', '<cmd>GitConflictChooseOurs<CR>', { desc = 'choose ours' } },
      { 'p', '<cmd>GitConflictPrevConflict<CR>', { desc = 'move to prev conflict', exit = false } },
      { 't', '<cmd>GitConflictChooseTheirs<CR>', { desc = 'choose theirs' } },
      { 'q', nil, { exit = true, nowait = true, desc = 'exit' } },
    },
  }):activate()
end

M.open_git_signs_hydra = function()
  local hint = [[
    _d_: Diff this     _s_: Stage hunk     _r_: Reset hunk
    _S_: Stage buffer  _u_: Undo stage     _R_: Reset buffer
    _p_: Preview hunk  _b_: Blame line     _B_: Toggle blame
    _x_: Select hunk   _q_: Exit
  ]]
  local Hydra = require('hydra')
  Hydra({
    config = {
      exit = true,
      color = 'blue',
      hint = {
        border = Ty.Config.ui.float.border,
      },
    },
    name = 'Gitsigns',
    hint = hint,
    heads = {
      { 'd', '<cmd>Gitsigns diffthis<cr>', { desc = 'Diff this' } },
      { 's', '<cmd>Gitsigns stage_hunk<cr>', { desc = 'Stage hunk' } },
      { 'r', '<cmd>Gitsigns reset_hunk<cr>', { desc = 'Reset hunk' } },
      { 'S', '<cmd>Gitsigns stage_buffer<cr>', { desc = 'Stage the buffer ' } },
      { 'u', '<cmd>Gitsigns undo_stage_hunk<cr>', { desc = 'Undo stage hunk' } },
      { 'R', '<cmd>Gitsigns reset_buffer<cr>', { desc = 'Reset buffer' } },
      { 'p', '<cmd>Gitsigns preview_hunk<cr>', { desc = 'Preview hunk' } },
      { 'b', '<cmd>Gitsigns blame_line<cr>', { desc = 'Blame line' } },
      { 'B', '<cmd>Gitsigns toggle_current_line_blame<cr>', { desc = 'Toggle current line blame' } },
      { 'x', '<cmd>Gitsigns select_hunk<cr>', { desc = 'Select hunk' } },
      { 'q', nil, { exit = true, nowait = true, desc = 'Exit' } },
    },
  }):activate()
end

return M
