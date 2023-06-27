local repos = {}
local optional_repos = {}
local merged = nil

local function plugin(spec)
  --- if spec has .optional property, it meant to merge with other spec,
  --- we need put it at the last of repos.
  if spec.optional == true then
    table.insert(optional_repos, spec)
    return
  end
  table.insert(repos, spec)
end

---@description Register spec into repos table, if spec is table[] type, recursively call this function
---@param spec table
local function plug(spec)
  if type(spec) == 'table' and type(spec[1]) == 'table' then
    for _, v in ipairs(spec) do
      plugin(v)
    end
  else
    plugin(spec)
  end

  return spec
end

return {
  repos = function()
    if merged ~= nil then return merged end
    merged = repos
    for _,v in ipairs(optional_repos) do 
      table.insert(merged, v)
    end
    return merged
  end,
  plug = plug,
}
