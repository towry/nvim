-- TODO: handle deleted path
local M = {}

M.Weights = {
  Recent = 1,
  Frecent = 0.5,
  Frequent = 0,
}

---@param cwd string
---@param local_opts? { weight_name?:string, filter?:string}
function M.select_by_cwd(cwd, local_opts)
  local_opts = local_opts or {}
  local weight_name = local_opts.weight_name or 'Recent'
  local weight = M.Weights[weight_name]
  if weight == nil then
    weight = M.Weights.Recent
  end
  local visits = require('mini.visits')
  local sort = visits.gen_sort.default({ recency_weight = weight })
  local select_opts = { sort = sort, filter = local_opts.filter }
  cwd = cwd or vim.uv.cwd()
  return visits.select_path(cwd, select_opts)
end

function M.add_project(project_path, cwd)
  local visits = require('mini.visits')
  visits.add_label('project', project_path, cwd)
  visits.write_index()
end

--- @param bufnr number
--- @param cwd? string
function M.is_buf_harpoon(bufnr, cwd)
  if vim.b[bufnr].is_harpoon ~= nil then
    return vim.b[bufnr].is_harpoon
  end

  cwd = cwd or vim.cfg.runtime__starts_cwd
  local bufpath = vim.api.nvim_buf_get_name(bufnr)
  local visits = require('mini.visits')
  local list = visits.list_paths(cwd, {
    filter = function(path_data)
      return (path_data.labels or {})['harpoon'] and (bufpath == path_data.path)
    end,
  })
  local is = list and #list > 0
  -- cache
  if is then
    vim.b[bufnr].is_harpoon = true
  else
    vim.b[bufnr].is_harpoon = false
  end
  return is
end

function M.list_projects_in_cwd(cwd, label)
  label = label or 'project'
  local extra = require('mini.extra')
  local path = require('userlib.runtime.path')
  extra.pickers.visit_paths({ cwd = cwd, filter = label, recency_weight = 0 }, {
    source = {
      choose = function(item)
        local full_path = path.path_join(cwd, item)
        vim.schedule(function()
          require('userlib.mini.clue.folder-action').open(full_path)
        end)
      end,
    },
  })
end

function M.list_oil_folders_in_cwd(cwd)
  local extra = require('mini.extra')
  local path = require('userlib.runtime.path')
  extra.pickers.visit_paths({ cwd = cwd, filter = 'oil-folder-visited', recency_weight = 0 }, {
    source = {
      choose = function(item)
        local full_path = path.path_join(cwd, item)
        vim.schedule(function()
          require('userlib.mini.clue.folder-action').open(full_path)
        end)
      end,
    },
  })
end

return M
