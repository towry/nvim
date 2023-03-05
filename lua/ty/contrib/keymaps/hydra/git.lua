local M = {}

M.open_git_conflict_hydra = function()
  local hint = [[
    _b_: Choose both     _n_: Next conflict  _o_: Choose ours  
    _p_: Prev conflict   _t_: Choose theirs  _q_: Exit
]]
  local Hydra = require('hydra')
  Hydra({
    name = 'Git conflict',
    hint = hint,
    options = {},
    heads = {
      { 'b', '<cmd>GitConflictChooseBoth<CR>', { desc = 'choose both' } },
      { 'n', '<cmd>GitConflictNextConflict<CR>', { desc = 'move to next conflict' } },
      { 'o', '<cmd>GitConflictChooseOurs<CR>', { desc = 'choose ours' } },
      { 'p', '<cmd>GitConflictPrevConflict<CR>', { desc = 'move to prev conflict' } },
      { 't', '<cmd>GitConflictChooseTheirs<CR>', { desc = 'choose theirs' } },
      { 'q', nil, { exit = true, nowait = true, desc = 'exit' } },
    },
  }):activate()
end

return M
