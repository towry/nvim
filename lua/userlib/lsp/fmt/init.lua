-- https://github.com/mrjones2014/dotfiles/blob/master/nvim/lua/my/lsp/utils/init.lua

local Methods = vim.lsp.protocol.Methods
local M = {}
local init_done = false
local formatting_enabled = true

function M.on_attach(client, bufnr)
  if not init_done then
    init_done = true
    M.setup_async_formatting()
  end
  -- Run eslint fixes before writing
  if client.name == 'eslint' then
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'EslintFixAll',
    })
  end
  vim.api.nvim_create_autocmd('BufWritePost', {
    buffer = bufnr,
    callback = function() M.format_document(bufnr) end,
  })
end

function M.setup_async_formatting()
  -- format on save asynchronously, see M.format_document
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
      vim.api.nvim_err_write(err)
      return
    end

    if result == nil then return end


    local is_ok, format_changedtick = pcall(vim.api.nvim_buf_get_var, ctx.bufnr, 'format_changedtick')
    local _, changedtick = pcall(vim.api.nvim_buf_get_var, ctx.bufnr, 'changedtick')

    if is_ok and format_changedtick == changedtick then
      local view = vim.fn.winsaveview()
      vim.lsp.util.apply_text_edits(result, ctx.bufnr, 'utf-16')
      vim.fn.winrestview(view)
      if ctx.bufnr == vim.api.nvim_get_current_buf() then
        vim.b.format_saving = true
        vim.cmd('noau update')
        vim.b.format_saving = false
      end
    end
  end
end

function M.toggle_formatting_enabled(enable)
  if enable == nil then enable = not formatting_enabled end
  if enable then
    formatting_enabled = true
    vim.notify('Enabling LSP formatting...', vim.log.levels.INFO)
  else
    formatting_enabled = false
    vim.notify('Disabling LSP formatting...', vim.log.levels.INFO)
  end
end

---@param buf number|nil defaults to 0 (current buffer)
---@return string|nil
function M.get_formatter_name(buf)
  buf = buf or tonumber(vim.g.actual_curbuf or vim.api.nvim_get_current_buf())

  -- if it uses efm-langserver, grab the formatter name
  local ft_efm_cfg = require('userlib.lsp.filetypes').config[vim.bo[buf].filetype]
  if ft_efm_cfg and ft_efm_cfg.formatter then
    if type(ft_efm_cfg.formatter) == 'table' then
      return ft_efm_cfg.formatter[1]
    else
      return tostring(ft_efm_cfg.formatter)
    end
  end

  -- otherwise just return the LSP server name
  local clients = vim.lsp.get_clients({ bufnr = buf, method = Methods.textDocument_formatting })
  if #clients > 0 then return clients[1].name end

  return nil
end

---@param buf number|nil defaults to 0 (current buffer)
---@return boolean
function M.is_formatting_supported(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not formatting_enabled then return false end
  if vim.b[buf].autoformat_disable then return false end

  local fsize = require('userlib.runtime.buffer').getfsize(buf)
  if fsize / 1024 > 200 then
    -- great than 200kb
    vim.notify('File is too large to format', vim.log.levels.WARN)
    return false
  end

  local clients = vim.lsp.get_clients({ bufnr = buf, method = Methods.textDocument_formatting })
  return #clients > 0
end

function M.format_document(buf)
  if not M.is_formatting_supported(buf) then return end

  if not vim.b.format_saving then
    vim.b.format_changedtick = vim.b.changedtick ---@diagnostic disable-line
    local formats_with_efm = require('userlib.lsp.filetypes').formats_with_efm()
    vim.lsp.buf.format({
      async = true,
      filter = function(client)
        if formats_with_efm then
          return client.name == 'efm'
        else
          return client.name ~= 'efm'
        end
      end,
    })
  end
end

return M
