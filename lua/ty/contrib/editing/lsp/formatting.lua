local M = {}

-- autoformat.
local format_disabled = false

function M.toggle_format()
  format_disabled = not format_disabled
  if format_disabled then
    Ty.NOTIFY('Auto format is disabled')
  else
    Ty.NOTIFY('Auto format is enabled')
  end
end

function M.current_formatter_name(bufnr)
  return vim.api.nvim_buf_get_var(bufnr or 0, 'formatter_name')
end

function M.format(bufnr, opts)
  opts = opts or {}

  if format_disabled and opts.auto then return end

  local _, name = pcall(vim.api.nvim_buf_get_var, bufnr or 0, 'formatter_name')
  local fmt_opts = {
    bufnr = bufnr,
    async = opts.async or false,
  }
  if name then
    fmt_opts.name = name
  end

  vim.notify("format ...")
  vim.lsp.buf.format(fmt_opts)
end

function M.setup_autoformat(client, buf)
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
    vim.api.nvim_buf_set_var(buf or 0, 'formatter_name', client.name or nil)
    vim.api.nvim_create_autocmd(event_name, {
      pattern = "*",
      group = vim.api.nvim_create_augroup("AutoFormat", { clear = false }),
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
