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

function M.add_project(project_path, cwd)
  local visits = require('mini.visits')
  visits.add_path(project_path, cwd)
  visits.add_label('project', project_path, cwd)
  visits.write_index()
end

function M.list_projects_in_cwd(cwd)
  local extra = require('mini.extra')
  extra.pickers.visit_paths({ cwd = cwd, filter = 'project', recency_weight = 0 }, {
    source = {
      choose = function(item)
        vim.print(item)
      end
    }
  })
end

return M
