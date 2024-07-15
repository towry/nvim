local M = {}

--- For first max 100 lines, find the firt import_statement with
--- `vim.treesitter.get_node`
--- @param opts? {node_types?:string[], regex_tester?:function}
--- @return number|nil
function M.get_first_import_statement_linenr(opts)
  opts = opts or {}
  local regex_tester = opts.regex_tester
  local node_types = opts.node_types or { 'import_statement', 'import_from_statement' }

  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, 100, false)
  for linenr, _ in ipairs(lines) do
    local node = vim.treesitter.get_node({
      bufnr = buf,
      pos = { linenr - 1, 0 },
    })
    if node ~= nil and (vim.tbl_contains(node_types, node:type())) then
      return linenr
    end
    -- use regex_tester to test line string
    if regex_tester ~= nil and regex_tester(lines[linenr]) == true then
      return linenr
    end
  end
  return nil
end

return M
