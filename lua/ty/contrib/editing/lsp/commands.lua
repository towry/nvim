-- https://github.com/leaxoy/v/blob/37d8558dde2117b7c188f4e2687d892dbcff7b53/lua/lsp/init.lua
-- not working.
function OrganizeImports(timeout_ms)
  local context = { only = { "source.organizeImports" } }
  vim.validate({ context = { context, "t", true } })

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  print(vim.inspect(result))
  for client_id, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      local encoding = (vim.lsp.get_client_by_id(client_id) or {}).offset_encoding or "utf-16"
      vim.lsp.util.apply_workspace_edit(r.edit, encoding)
    end
  end
end

return {
  OrganizeImports = {
    function() OrganizeImports(1000) end,
    description = "Organize imports",
  }
}
