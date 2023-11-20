---@param default_capabilities? table
return function(default_capabilities)
  local capabilities = default_capabilities or require('cmp_nvim_lsp').default_capabilities()

  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  capabilities.workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    }
  }

  return capabilities
end
