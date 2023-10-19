local autoformat = require('userlib.lsp.servers.null_ls.autoformat')

---formatter name that corresponds to client name.
local ft_client_formatter = {}
---formatter name that the client use under the hood.
local ft_impl_formatter = {}

local M = {}

--- @perf use ft instead of specific bufnr.
function choose_formatter_for_buf(client, buf)
  local ft = vim.api.nvim_get_option_value("filetype", {
    buf = buf,
  })

  if ft_client_formatter[ft] then
    return
  end

  local nls = require('userlib.lsp.servers.null_ls.utils')
  local nls_available_formatters = nls.get_available_formatters(ft)
  local specific_formatter_name = nil

  local enable = false
  if nls.has_formatter(ft, nls_available_formatters) then
    enable = client.name == 'null-ls'
    specific_formatter_name = nls.format_available_formatters(nls_available_formatters)
  else
    enable = client.server_capabilities.documentFormattingProvider and
        not vim.tbl_contains({ 'null-ls', 'tsserver' }, client.name)
  end

  if enable then
    ft_impl_formatter[ft] = specific_formatter_name or client.name
    ft_client_formatter[ft] = client.name
  end
end

--- Our custom format function.
---@param opts {auto?:boolean, async?:boolean}
function M.format(bufnr, opts)
  opts = opts or {}

  local fsize = require('userlib.runtime.buffer').getfsize(bufnr)
  if fsize / 1024 > 200 then
    -- great than 200kb
    vim.notify('File is too large to format', vim.log.levels.WARN)
    return
  end

  if autoformat.disabled() and opts.auto then return end

  local name, impl_formatter_name = M.current_formatter_name(bufnr or 0)
  local fmt_opts = {
    bufnr = bufnr,
    async = opts.async or false,
  }
  if name then
    fmt_opts.name = name
  end

  vim.lsp.buf.format(fmt_opts)
  if not opts.auto then
    vim.api.nvim_echo({ { "format with " .. (impl_formatter_name or name or "default"), "Comment" } }
    , true, {})
  else
    vim.defer_fn(function()
      vim.api.nvim_echo({ { " written! also format with " .. (impl_formatter_name or name or "default"), "Comment" } }
      , true, {})
    end, 100)
  end
end

---@return string|nil, string|nil
function M.current_formatter_name(bufnr)
  local ft = vim.api.nvim_get_option_value("filetype", {
    buf = bufnr,
  })

  local impl_name = ft_impl_formatter[ft] or nil
  local value = ft_client_formatter[ft] or nil
  return value, impl_name
end

function M.attach(client, bufnr)
  choose_formatter_for_buf(client, bufnr)
  autoformat.attach_autoformat_with_autocmd(client, bufnr)
end

return M
