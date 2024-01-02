local ts_conds = require('nvim-autopairs.ts-conds')
local cond = require('nvim-autopairs.conds')
local npairs = require('nvim-autopairs')
local Rule = require('nvim-autopairs.rule')

local M = {}

-- nvim-autopairs rule
-- to auto add closing tag in jsx.
function M.auto_jsx_closing()
  local default_pa_rule = npairs.get_rule('(')
  npairs.remove_rule('(')
  npairs.add_rules({
    default_pa_rule:with_pair(cond.not_inside_quote(), 1),
    -- in jsx
    -- <SomeEle /  => <SomeEle />
    Rule('/', '>', { 'typescriptreact', 'javascriptreact' })
      :with_pair(function(opts)
        local before_text_fn = cond.before_text(' ')
        local is_ts_node_fn = ts_conds.is_ts_node({ 'jsx_self_closing_element' })

        return before_text_fn(opts) and is_ts_node_fn and is_ts_node_fn(opts)
      end)
      :set_end_pair_length(0)
      :with_move(cond.none()),
  })
end

return M
