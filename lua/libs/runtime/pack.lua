local repos = {}

local function plugin(spec)
  if spec and spec.enabled == false then
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
  repos = repos,
  plug = plug,
}
