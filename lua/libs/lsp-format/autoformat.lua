local auto_format_disabled = true

local M = {}

--- Is auto format is disabled
function M.disabled()
  return auto_format_disabled
end

--- Enable the autoformat feature.
function M.enable()
  local ok, lsp_format = pcall(require, 'lsp-format')
  if not ok then
    vim.notify("Fail to enable autoformat")
    return
  end
  auto_format_disabled = false
  lsp_format.enable({
    args = ""
  })
end

function M.toggle()
  local ok, lsp_format = pcall(require, 'lsp-format')
  if not ok then
    return
  end

  auto_format_disabled = not auto_format_disabled
  if auto_format_disabled then
    vim.notify('Auto format is disabled')
    lsp_format.disable({
      args = ""
    })
  else
    lsp_format.enable({
      args = ""
    })
    vim.notify('Auto format is enabled')
  end
end

function M.attach(client, bufnr)
  local ok, lsp_format = pcall(require, 'lsp-format')
  if not ok then
    return
  end

  lsp_format.on_attach(client, bufnr)

  if M.disabled() then
    lsp_format.disable({
      args = ""
    })
  end
end

return M
