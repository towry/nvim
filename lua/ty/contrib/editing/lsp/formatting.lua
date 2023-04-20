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

function M.setup_autoformat(client, buf)
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local nls = require('ty.contrib.editing.lsp.null-ls')

  local enable = false
  if nls.has_formatter(ft) then
    enable = client.name == 'null-ls'
  else
    enable = client.server_capabilities.documentFormattingProvider and
        not vim.tbl_contains({ 'null-ls', 'tsserver' }, client.name)
  end

  -- format on save
  if enable then
    vim.b[buf].formatter_name = client.name or nil
    require('lsp-format').on_attach(client)
  end
end

function M.setup_autoformat_deprecated(client, buf)
  local event_name = "BufWritePre"
  local async = event_name == "BufWritePost"
  local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  local nls = require('ty.contrib.editing.lsp.null-ls')

  local enable = false
  if nls.has_formatter(ft) then
    enable = client.name == 'null-ls'
  else
    enable = client.server_capabilities.documentFormattingProvider and
        not vim.tbl_contains({ 'null-ls', 'tsserver' }, client.name)
  end

  -- format on save
  if enable then
    vim.b[buf].formatter_name = client.name or nil
    vim.api.nvim_create_autocmd(event_name, {
      buffer = buf,
      group = vim.api.nvim_create_augroup("AutoFormat_" .. buf, { clear = true }),
      callback = function(ctx)
        M.format(ctx.buf, {
          async = async,
          auto = true,
        })
      end,
    })
  end
end

return M
