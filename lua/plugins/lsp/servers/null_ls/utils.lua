local M = {}

function M.get_available_formatters(ft)
  local sources = require('null-ls.sources')
  local available = sources.get_available(ft, 'NULL_LS_FORMATTING')
  return available
end

function M.has_formatter(ft, available_formatters)
  local available = available_formatters or M.get_available_formatters(ft)
  return #available > 0
end

---@param available table
---@param seprator? string
function M.format_available_formatters(available, seprator)
  seprator = seprator or ', '
  if not available or type(available) ~= 'table' or #available == 0 then
    return nil
  end
  return table.concat(
    vim.tbl_map(function(x)
      return x.name
    end, available),
    seprator
  )
end

return M
