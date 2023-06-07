-- Custom textDocument/hover LSP handler to colorize colors inside hover results - WIP
local function custom_hover_handler(_, result)
  local handler = function(_, result)
    if result then
      local lines = vim.split(result.contents.value, '\n')
      local bufnr =
          vim.lsp.util.open_floating_preview(lines, 'markdown', { border = 'rounded' })
      require('colorizer').highlight_buffer(
        bufnr,
        nil,
        vim.list_slice(lines, 2, #lines),
        0,
        require('colorizer').get_buffer_options(0)
      )
    end
  end

  return handler
end

local handlers = {
  ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
  ['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = 'rounded' }
  ),
}

return handlers
