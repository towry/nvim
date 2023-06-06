local handlers = {
  ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = Ty.Config.ui.float.border }),
  ['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = vim.cfg.ui__float_border }
  ),
}

return handlers
