local auto_format_disabled = false

local M = {}

--- Is auto format is disabled
function M.disabled(bufnr)
  -- do not format on git merge.
  if vim.cfg.runtime__starts_as_gittool then return end
  if (bufnr or bufnr == 0) and vim.b[bufnr].autoformat_disable then
    return true
  end
  return auto_format_disabled
end

--- Enable the autoformat feature.
function M.enable()
  auto_format_disabled = false
end

function M.toggle()
  auto_format_disabled = not auto_format_disabled
  if auto_format_disabled then
    vim.notify('Auto format is disabled', nil, { key = 'autoformat' })
  else
    vim.notify('Auto format is enabled', nil, { key = 'autoformat' })
  end
  vim.api.nvim_exec_autocmds('User', { pattern = 'StatuslineUpdate' })
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
  local async = true
  -- make sure event is post if is async, otherwise changedtick will not match.
  local event_name = async and 'BufWritePost' or 'BufWritePre'
  vim.api.nvim_clear_autocmds({
    group = group,
    buffer = bufnr,
  })
  au.define_autocmds({
    {
      { event_name },
      {
        group = group,
        buffer = bufnr,
        nested = false,
        desc = "Auto format for buffer: " .. bufnr,
        callback = function()
          require('userlib.lsp.servers.null_ls.fmt').format(bufnr, {
            auto = true,
            async = async,
          })
        end
      }
    }
  })
end

function M.attach(client, bufnr)
  attach_autoformat_with_autocmd(client, bufnr)
  vim.api.nvim_exec_autocmds('User', { pattern = 'StatuslineUpdate' })
end

return M
