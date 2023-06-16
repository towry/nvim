local auto_format_disabled = true

local M = {}

--- Is auto format is disabled
function M.disabled()
  return auto_format_disabled
end

--- Enable the autoformat feature.
function M.enable()
  local ok, lsp_format = pcall(require, 'lsp-format')
  auto_format_disabled = false
  if not ok then
    return
  end
  lsp_format.enable({
    args = ""
  })
end

function M.toggle()
  local ok, lsp_format = pcall(require, 'lsp-format')
  auto_format_disabled = not auto_format_disabled
  if auto_format_disabled then
    vim.notify('Auto format is disabled')
    if ok then
      lsp_format.disable({
        args = ""
      })
    end
  else
    if ok then
      lsp_format.enable({
        args = ""
      })
    end
    vim.notify('Auto format is enabled')
  end
end

local function attach_autoformat_with_autocmd(_client, bufnr)
  local au = require('libs.runtime.au')
  au.define_autocmds({
    {
      { 'BufWritePre' },
      {
        group = '_lsp_format',
        buffer = bufnr,
        nested = false,
        callback = function()
          require('libs.lsp-format').format(bufnr, {
            auto = true,
            async = false,
          })
        end
      }
    }
  })
end

function M.attach(client, bufnr)
  local ok, lsp_format = pcall(require, 'lsp-format')
  if not ok then
    attach_autoformat_with_autocmd(client, bufnr)
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
