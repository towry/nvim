local autoformat = require('userlib.lsp.servers.null_ls.autoformat')
local Methods = vim.lsp.protocol.Methods
local async_format_setup_done = false
---formatter name that corresponds to client name.
local ft_client_formatter = {}
---formatter name that the client use under the hood.
local ft_impl_formatter = {}

local M = {}

local function setup_async_formatting()
  vim.lsp.handlers[Methods.textDocument_formatting] = function(err, result, ctx)
    if err ~= nil then
      -- efm uses table messages
      if type(err) == 'table' then
        if err.message then
          err = err.message
        else
          err = vim.inspect(err)
        end
      end
      vim.api.nvim_err_write(tostring(err))
      return
    end

    if result == nil then
      return
    end

    local is_ok, format_context = pcall(vim.api.nvim_buf_get_var, ctx.bufnr, 'format_context')
    local _, changedtick = pcall(vim.api.nvim_buf_get_var, ctx.bufnr, 'changedtick')

    if is_ok and format_context.tick == changedtick then
      local view = vim.fn.winsaveview()
      vim.lsp.util.apply_text_edits(result, ctx.bufnr, 'utf-16')
      if view then
        vim.fn.winrestview(view)
      end
      if ctx.bufnr == vim.api.nvim_get_current_buf() and format_context.write then
        vim.b.format_saving = true
        vim.cmd('silent! noau update')
        vim.b.format_saving = false
      elseif not format_context.write then
        vim.b.format_saving = false
      end
    end
  end
end

--- @perf use ft instead of specific bufnr.
local function choose_formatter_for_buf(client, buf)
  local ft = vim.api.nvim_get_option_value('filetype', {
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
    enable = client.server_capabilities.documentFormattingProvider
      and not vim.tbl_contains({ 'null-ls', 'tsserver' }, client.name)
  end

  if enable then
    ft_impl_formatter[ft] = specific_formatter_name or client.name
    ft_client_formatter[ft] = client.name
  end
end

--- Our custom format function.
---@param opts {auto?:boolean, async?:boolean, write?:boolean}
function M.format(bufnr, opts)
  opts = opts or {}

  local fsize = require('userlib.runtime.buffer').getfsize(bufnr)
  if fsize / 1024 > 200 then
    -- great than 200kb
    vim.notify('File is too large to format', vim.log.levels.WARN)
    return
  end

  if autoformat.disabled(bufnr) and opts.auto then
    return
  end
  if vim.b.format_saving then
    return
  end
  local is_ok, format_context = pcall(vim.api.nvim_buf_get_var, bufnr, 'format_context')
  if is_ok and format_context.tick == vim.b.changedtick then
    return
  end

  vim.b.format_context = {
    tick = vim.b.changedtick,
    write = opts.write,
  }

  local name, _ = M.current_formatter_name(bufnr or 0)
  local fmt_opts = {
    bufnr = bufnr,
    async = opts.async or false,
  }
  if name then
    fmt_opts.name = name
  end

  vim.lsp.buf.format(fmt_opts)
end

---@return string|nil, string|nil
function M.current_formatter_name(bufnr)
  local ft = vim.api.nvim_get_option_value('filetype', {
    buf = bufnr,
  })

  local impl_name = ft_impl_formatter[ft] or nil
  local value = ft_client_formatter[ft] or nil
  return value, impl_name
end

function M.attach(client, bufnr)
  if not async_format_setup_done then
    async_format_setup_done = true
    setup_async_formatting()
  end
  choose_formatter_for_buf(client, bufnr)
  autoformat.attach(client, bufnr)
end

return M
