local autoformat = require('libs.lsp-format.autoformat')

local ft_formatter = {}
local buf_formatters = {}

local M = {}

function M.choose_formatter_for_buf(client, buf)
  if buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  local ft = vim.api.nvim_get_option_value("filetype", {
    buf = buf,
  })

  if ft_formatter[ft] then
    vim.b[buf].formatter_name = ft_formatter[ft]
    return
  end

  local nls = require('libs.lspconfig-servers.null_ls.utils')
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

  -- format on save
  if enable then
    buf_formatters[buf] = specific_formatter_name or client.name
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

  local name, specific_format_name = M.current_formatter_name(bufnr or vim.api.nvim_get_current_buf())
  local fmt_opts = {
    bufnr = bufnr,
    async = opts.async or false,
  }
  if name then
    fmt_opts.name = name
  end

  vim.lsp.buf.format(fmt_opts)
  if not opts.auto then
    vim.api.nvim_echo({ { "format with " .. (specific_format_name or name or "default"), "Comment" } }
    , true, {})
  else
    vim.defer_fn(function()
      vim.api.nvim_echo({ { " written! also format with " .. (specific_format_name or name or "default"), "Comment" } }
      , true, {})
    end, 100)
  end
end

---@return string|nil, string|nil
function M.current_formatter_name(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local specific = buf_formatters[bufnr] or nil
  local ok, value = pcall(vim.api.nvim_buf_get_var, bufnr or 0, 'formatter_name')
  if ok then
    return value, specific
  else
    return nil, nil
  end
end

return M
