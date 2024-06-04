local function add_snippet_compa(cap)
  cap.textDocument.completion = {
    dynamicRegistration = false,
    contextSupport = true,
    completionItem = {
      deprecatedSupport = true,
      insertReplaceSupport = true,
      commitCharactersSupport = true,
      -- insertTextModeSupport = { valueSet = { 1, 2 } },
      labelDetailsSupport = true,
      preselectSupport = true,
      -- tagSupport = { valueSet = { 1 } },
      snippetSupport = true,
      resolveSupport = {
        properties = { 'edit', 'documentation', 'detail', 'additionalTextEdits' },
      },
    },
    completionList = {
      itemDefaults = {
        'commitCharacters',
        'editRange',
        'insertTextFormat',
        'insertTextMode',
        'data',
      },
    },
  }
  return cap
end

---@param default_capabilities? table
return function(default_capabilities)
  local capabilities = default_capabilities
  if not capabilities then
    if vim.cfg.edit__use_native_cmp then
      capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = add_snippet_compa(capabilities)
    else
      capabilities = require('cmp_nvim_lsp').default_capabilities()
    end
  end

  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  capabilities.workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    },
  }

  return capabilities
end
