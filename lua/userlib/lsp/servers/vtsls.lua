local M = {}

M.cmd = {
  'node',
  vim.cfg.lsp__vtsls or 'vtsls',
  '--stdio',
}

return M
