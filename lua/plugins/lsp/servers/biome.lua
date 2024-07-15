local utils = require('lspconfig.util')
local M = {}

M.cmd = {
  vim.cfg.lsp_biome or 'biome',
  'lsp-proxy',
}

--- Only attach this lsp if biome config file exists.
M.root_dir = utils.root_pattern('biome.json', 'biome.jsonc')

return M
