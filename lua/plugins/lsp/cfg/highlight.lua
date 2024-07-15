local M = {}

function M.on_attach(client, bufnr)
  if not client.server_capabilities.documentHighlightProvider then
    return
  end

  vim.b[bufnr].minicursorword_disable = true

  vim.lsp.buf.clear_references()

  vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true })
  vim.api.nvim_clear_autocmds({ buffer = bufnr, group = 'lsp_document_highlight' })
  vim.api.nvim_create_autocmd('CursorMoved', {
    callback = vim.lsp.buf.clear_references,
    buffer = bufnr,
    group = 'lsp_document_highlight',
    desc = 'Clear All the References',
  })
  vim.api.nvim_create_autocmd('CursorHold', {
    callback = vim.lsp.buf.document_highlight,
    buffer = bufnr,
    group = 'lsp_document_highlight',
    desc = 'Document Highlight',
  })
end

return M
