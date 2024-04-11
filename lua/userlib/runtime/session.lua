local M = {}

function M.encode_session_vars()
  if not vim.json then
    return
  end

  --- store some vars into this object
  --- for each tabs,
  --- -- store the vim.t[tabIdx].Cwd
  --- -- store the vim.t[tabIdx].CwdLocked
  --- -- store the vim.t[tabIdx].TabLabel
  --- -- store the vim.t[tabIdx].CwdShort
  local vars = {
    tabs = {},
  }

  for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
    vars.tabs[tabnr] = {
      Cwd = vim.t[tabnr].Cwd,
      CwdLocked = vim.t[tabnr].CwdLocked,
      TabLabel = vim.t[tabnr].TabLabel,
      CwdShort = vim.t[tabnr].CwdShort,
    }
  end

  vim.g.SessionJson = vim.json.encode(vars)
end

function M.decode_session_vars()
  if not vim.g.SessionJson or not vim.json then
    return
  end

  local vars = vim.json.decode(vim.g.SessionJson)
  return vars
end

--- @params tabs table
function M.restore_tabs_vars(tabs)
  if type(tabs) ~= 'table' then
    return
  end

  for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
    if tabs[tabnr] then
      vim.t[tabnr].Cwd = tabs[tabnr].Cwd
      vim.t[tabnr].CwdLocked = tabs[tabnr].CwdLocked
      vim.t[tabnr].TabLabel = tabs[tabnr].TabLabel
      vim.t[tabnr].CwdShort = tabs[tabnr].CwdShort
    end
  end
end

return M
