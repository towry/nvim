local M = {}

local format_disabled = false

function M.toggle_format()
  format_disabled = not format_disabled
  if format_disabled then
    Ty.NOTIFY('Auto format is disabled')
  else
    Ty.NOTIFY('Auto format is enabled')
  end
end

function M.format(bufnr)
  if format_disabled and not bufnr then return end

  vim.lsp.buf.format({
    bufnr = bufnr,
  })
end

function M.setup_autoformat(client, buf)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local nls = require('ty.contrib.editing.lsp.null-ls')

  local enable = false
  if nls.has_formatter(ft) then
    enable = client.name == 'null-ls'
  else
    enable = not (client.name == 'null-ls')
  end

  if client.name == 'tsserver' then enable = false end

  client.server_capabilities.documentFormattingProvider = enable
  -- format on save
  if client.server_capabilities.documentFormattingProvider then
    vim.cmd([[
		augroup LspFormat
		  autocmd! * <buffer>
		  autocmd BufWritePre <buffer> lua require("ty.contrib.editing.lsp.formatting").format()
		augroup END
	  ]])
  end
end

return M
