local M = {}

M.Weights = {
  Recent = 1,
  Frecent = 0.5,
  Frequent = 0
}

---@param cwd string
---@param weight_name? string
function M.select_by_cwd_and_weight(cwd, weight_name)
  local weight = M.Weights[weight_name]
  if weight == nil then weight = M.Weights.Recent end
  local visits = require('mini.visits')
  local sort = visits.gen_sort.default({ recency_weight = weight })
  local select_opts = { sort = sort }
  cwd = cwd or vim.uv.cwd()
  return visits.select_path(cwd, select_opts)
end

return M
