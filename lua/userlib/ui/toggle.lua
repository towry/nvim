--- credits: AstroNvim
local M = {}
local function ui_notify(silent, ...)
  return not silent and vim.notify(...)
end
local function bool2str(bool)
  return bool and 'on' or 'off'
end

--- Toggle buffer semantic token highlighting for all language servers that support it
---@param bufnr? number the buffer to toggle the clients on
---@param silent? boolean if true then don't sent a notification
---@param clients_? table a list of clients to toggle
function M.toggle_buffer_semantic_tokens(bufnr, silent, clients_)
  bufnr = bufnr or 0
  vim.b[bufnr].semantic_tokens_enabled = not vim.b[bufnr].semantic_tokens_enabled
  local clients = clients_ or vim.lsp.buf_get_clients({ bufnr = bufnr })
  local toggled = false
  for _, client in ipairs(clients) do
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens[vim.b[bufnr].semantic_tokens_enabled and 'start' or 'stop'](bufnr, client.id)
      toggled = true
    end
  end
  ui_notify(
    not toggled or silent,
    string.format('Buffer lsp semantic highlighting %s', bool2str(vim.b[bufnr].semantic_tokens_enabled))
  )
end

--- Toggle syntax highlighting and treesitter
---@param bufnr? number the buffer to toggle syntax on
---@param silent? boolean if true then don't sent a notification
function M.toggle_buffer_syntax(bufnr, silent)
  -- HACK: this should just be `bufnr = bufnr or 0` but it looks like `vim.treesitter.stop` has a bug with `0` being current
  bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_win_get_buf(0)
  local ts_avail, parsers = pcall(require, 'nvim-treesitter.parsers')
  if vim.bo[bufnr].syntax == 'off' then
    if ts_avail and parsers.has_parser() then
      vim.treesitter.start(bufnr)
    end
    vim.bo[bufnr].syntax = 'on'
    if not vim.b[bufnr].semantic_tokens_enabled then
      M.toggle_buffer_semantic_tokens(bufnr, true)
    end
  else
    if ts_avail and parsers.has_parser() then
      vim.treesitter.stop(bufnr)
    end
    vim.bo[bufnr].syntax = 'off'
    if vim.b[bufnr].semantic_tokens_enabled then
      M.toggle_buffer_semantic_tokens(bufnr, true)
    end
  end
  ui_notify(silent, string.format('syntax %s', vim.bo[bufnr].syntax))
end

return M
