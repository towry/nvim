local M = {}

function M.on_attach(client, bufnr)
  if not vim.cfg or not vim.lsp.completion then
    return
  end

  if vim.cfg.edit__use_coc or vim.cfg.edit__use_coq_cmp then
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

  vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
end

return M
