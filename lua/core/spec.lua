--- Disable a lazy spec
--- @param name string
local function dislike(name)
  return { name, enabled = false }
end

local not_inside_val = {
  git = false,
}
local not_inside = setmetatable({}, {
  __index = function(_, key)
    return not rawget(not_inside_val, key)
  end,
})

return {
  dislike = dislike,
  not_inside = not_inside,
}
