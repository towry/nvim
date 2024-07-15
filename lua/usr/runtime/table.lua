--- https://github.com/premake/premake-core/blob/master/src/base/table.lua
local M = {}

-- TODO: rename to lodash

function M.concat(tables)
  local result = {}
  for _, t in ipairs(tables) do
    for _, v in ipairs(t) do
      table.insert(result, v)
    end
  end
  return result
end

function M.reduce(callback, carry, t)
  for _, v in ipairs(t) do
    carry = callback(carry, v)
  end
  return carry
end

function M.filter(callback, t)
  return M.reduce(function(new_t, v)
    if callback(v) then
      table.insert(new_t, v)
    end
    return new_t
  end, {}, t)
end

function M.map(callback, t)
  return M.reduce(function(carry, v)
    table.insert(carry, callback(v))
    return carry
  end, {}, t)
end

---@param value_or_matcher string|number|function
function M.find(value_or_matcher, t)
  if type(value_or_matcher) == 'function' then
    for _, needle in ipairs(t) do
      if value_or_matcher(needle) then
        return needle
      end
    end
    return
  end
  for i, v in ipairs(t) do
    if value_or_matcher == v then
      return i
    end
    return nil
  end
end

function M.reverse(t)
  local reversed = {}
  for i = 1, #t do
    table.insert(reversed, t[#t + 1 - i])
  end
  return reversed
end

function M.head(n, t)
  return { unpack(t, 1, n + 1) }
end

---Determine if a value of any type is empty
---@param item any
---@return boolean?
function M.falsy(item)
  if not item then
    return true
  end
  local item_type = type(item)
  if item_type == 'boolean' then
    return not item
  end
  if item_type == 'string' then
    return item == ''
  end
  if item_type == 'number' then
    return item <= 0
  end
  if item_type == 'table' then
    return vim.tbl_isempty(item)
  end
  return item ~= nil
end

--- Convert a list or map of items into a value by iterating all it's fields and transforming
--- them with a callback
---@generic T, S
---@param callback fun(acc: S, item: T, key: string | number): S
---@param list T[]
---@param accum S?
---@return S
function M.fold(callback, list, accum)
  accum = accum or {}
  for k, v in pairs(list) do
    accum = callback(accum, v, k)
    assert(accum ~= nil, 'The accumulator must be returned on each iteration')
  end
  return accum
end

return M
