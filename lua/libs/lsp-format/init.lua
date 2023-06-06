local autoformat = require('libs.lsp-format.autoformat')

local ft_formatter = {}

local M = {}

function M.choose_formatter_for_buf(client, buf)
  local ft = vim.api.nvim_get_option_value("filetype", {
    buf = buf,
  })
  if ft_formatter[ft] then
    vim.b[buf].formatter_name = ft_formatter[ft]
    return
  end

  local nls = require('libs.lspconfig-servers.null_ls.utils')

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

--- Our custom format function.
---@param opts {auto?:boolean, async?:boolean}
function M.format(bufnr, opts)
  opts = opts or {}

  local fsize = require('libs.runtime.buffer').getfsize(bufnr)
  if fsize / 1024 > 200 then
    -- great than 200kb
    vim.notify('File is too large to format', vim.log.levels.WARN)
    return
  end

  if autoformat.disabled() and opts.auto then return end

  local name = vim.b[bufnr or vim.api.nvim_get_current_buf()].formatter_name or nil
  local fmt_opts = {
    bufnr = bufnr,
    async = opts.async or false,
  }
  if name then
    fmt_opts.name = name
  end

  vim.api.nvim_echo({ { "format with " .. (name or "default"), "Comment" } }, true, {})
  vim.lsp.buf.format(fmt_opts)
end

function M.current_formatter_name(bufnr)
  return vim.api.nvim_buf_get_var(bufnr or 0, 'formatter_name')
end

return M
