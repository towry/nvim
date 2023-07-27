return function(default_capabilities)
  local capabilities = default_capabilities or {}

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
