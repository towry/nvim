local M = {}

function M.on_attach(client, bufnr)
  if not vim.cfg or not vim.lsp.completion then
    return
  end

  local triggers = vim.tbl_get(client.server_capabilities, 'completionProvider', 'triggerCharacters')
  if triggers then
    for _, char in ipairs({ 'a', 'e', 'i', 'o', 'u' }) do
      if not vim.tbl_contains(triggers, char) then
        table.insert(triggers, char)
      end
    end
    for i, t in ipairs(triggers) do
      if t == ',' then
        triggers[i] = nil
      end
    end
    client.server_capabilities.completionProvider.triggerCharacters = vim.iter(triggers):totable()
  end

  if vim.edit__cmp_provider ~= 'native' then
    return
  end

  if not client.supports_method(Ty.lsp_methods().textDocument_completion) then
    return
  end

  vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
end

return M
