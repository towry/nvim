local Buffer = require('libs.runtime.buffer')

local M = {}

M.terms_count = function()
  local buffers = Buffer.list()
  local pattern = 'term://.*'
  local count = 0
  for _, bName in pairs(buffers) do
    if string.match(bName, pattern) ~= nil then
      count = count + 1
    end
  end

  return count
end

return M
