local M = {}

-- autoformat.
local auto_format_disabled = false

function M.auto_format_disabled()
  return auto_format_disabled
end

function M.toggle_format()
  local lsp_format = require('lsp-format')
  auto_format_disabled = not auto_format_disabled
  if auto_format_disabled then
    Ty.NOTIFY('Auto format is disabled')
    lsp_format.disable({
      args = ""
    })
  else
    lsp_format.enable({
      args = ""
    })
    Ty.NOTIFY('Auto format is enabled')
  end
end

function M.current_formatter_name(bufnr)
  return vim.api.nvim_buf_get_var(bufnr or 0, 'formatter_name')
end

function M.format(bufnr, opts)
  opts = opts or {}

  local fsize = require('ty.core.buffer').getfsize(bufnr)
  if fsize / 1024 > 200 then
    -- great than 200kb
    Ty.NOTIFY('File is too large to format', vim.log.levels.WARN)
    return
  end

  if auto_format_disabled and opts.auto then return end

  local name = vim.b[bufnr or vim.api.nvim_get_current_buf()].formatter_name or nil
  local fmt_opts = {
    bufnr = bufnr,
    async = opts.async or false,
  }
  if name then
    fmt_opts.name = name
  end

  Ty.ECHO({ { "format with " .. (name or "default"), "Comment" } }, true, {})
  vim.lsp.buf.format(fmt_opts)
end

local ft_formatter = {}

function M.set_formatter(client, buf)
  -- local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local ft = vim.api.nvim_get_option_value("filetype", {
    buf = buf,
  })
  if ft_formatter[ft] then
    vim.b[buf].formatter_name = ft_formatter[ft]
    return
  end

  local nls = require('user.plugins.lsp.null-ls')

  local enable = false
  if nls.has_formatter(ft) then
    enable = client.name == 'null-ls'
  else
    enable = client.server_capabilities.documentFormattingProvider and
        not vim.tbl_contains({ 'null-ls', 'tsserver' }, client.name)
  end

  -- format on save
  if enable then
    ft_formatter[ft] = client.name
    vim.b[buf].formatter_name = client.name or nil
  end
end

function M.set_autoformat_on_buf(client, buf)
  require('lsp-format').on_attach(client)
end

return M
