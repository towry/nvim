-- see https://github.com/Neelfrost/nvim-config/blob/0334e26af6a919241bda6274cea4da239e0accd9/lua/user/plugins/config/heirline/utils.lua#L157

local M = {}

M.lsp_status = function()
  local get_lsp_status = function(client_names)
    local progress = vim.lsp.util.get_progress_messages()
    -- Get lsp status for current buffer
    for _, v in ipairs(progress) do
      if vim.tbl_contains(client_names, v.name) or v.name == 'null-ls' then return v end
    end
  end

  local client_names = M.lsp_client_names()
  local lsp_status = get_lsp_status(client_names)

  -- Show client status
  if lsp_status and lsp_status.progress then
    local ret = lsp_status.title:gsub('^%l', string.upper)
      .. ' ['
      .. (lsp_status.percentage and (lsp_status.percentage .. '%%') or '✔')
      .. ']'
    return ret
  end
  return nil
end

M.lsp_client_names = function(shorten)
  local get_sources = function()
    local _, null_ls = pcall(require, 'null-ls.sources')
    local sources = null_ls.get_available(vim.bo.filetype)
    local names = {}

    for _, source in pairs(sources) do
      table.insert(names, source.name)
    end

    return names
  end

  -- Get all active clients in the buffer
  local clients = vim.lsp.buf_get_clients(0)
  local client_names = {}

  if not shorten then
    for _, client in pairs(clients) do
      if client.name ~= 'null-ls' then
        table.insert(client_names, client.name)
      else
        vim.list_extend(client_names, get_sources())
      end
    end
  else
    for _, client in pairs(clients) do
      table.insert(client_names, client.name)
    end
  end

  return client_names
end

local LspComponent = require('lualine.component'):extend()
local default_options = {}
LspComponent.init = function(self, options)
  LspComponent.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  -- self.clients = table.concat(M.lsp_client_names(), ", ")
  self.options.short_clients = table.concat(M.lsp_client_names(true), ', ')
  self.options.status = M.lsp_status() or ' '
end
LspComponent.update_status = function(self)
  self.options.status = M.lsp_status() or '✔ '
  -- maybe should update this in autocmd
  self.options.short_clients = table.concat(M.lsp_client_names(true), ', ')

  if self.options.short_clients == '' then return '' end

  return (self.options.short_clients .. ' ' .. self.options.status)
end

M.LspComponent = LspComponent

return M
