local auto_format_disabled = false

local M = {}

--- Is auto format is disabled
function M.disabled()
  return auto_format_disabled
end

--- Enable the autoformat feature.
function M.enable()
  auto_format_disabled = false
end

function M.toggle()
  auto_format_disabled = not auto_format_disabled
  if auto_format_disabled then
    vim.notify('Auto format is disabled')
  else
    vim.notify('Auto format is enabled')
  end
end

local function attach_autoformat_with_autocmd(_client, bufnr)
  local formatter_name, _ = require('userlib.lsp.servers.null_ls.fmt').current_formatter_name(bufnr)
  if not formatter_name then
    return
  end
  local au = require('userlib.runtime.au')
  local group = vim.api.nvim_create_augroup('_lsp_format_' .. bufnr, {
    clear = true,
  })
  vim.api.nvim_clear_autocmds({
    group = group,
    buffer = bufnr,
  })
  au.define_autocmds({
    {
      { 'BufWritePre' },
      {
        group = group,
        buffer = bufnr,
        nested = false,
        desc = "Auto format for buffer: " .. bufnr,
        callback = function()
          require('userlib.lsp.servers.null_ls.fmt').format(bufnr, {
            auto = true,
            async = false,
          })
        end
      }
    }
  })
end

function M.attach(client, bufnr)
  attach_autoformat_with_autocmd(client, bufnr)
end

return M