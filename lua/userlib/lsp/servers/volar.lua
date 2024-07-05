local M = {}

M.settings = {
  typescript = {
    inlayHints = {
      functionLikeReturnTypes = {
        enabled = true,
      },
      propertyDeclarationTypes = {
        enabled = true,
      },
      parameterTypes = {
        enabled = true,
      },
      variableTypes = {
        enabled = true,
      },
    },
  },
}

--- https://github.com/volarjs/volar.js/blob/master/packages/language-server/lib/types.ts

return function()
  local utils = require('userlib.runtime.utils')
  local node_root = utils.get_root()
  local node_util = require('userlib.runtime.platform.nodejs')

  local fts = vim.cfg.lsp__server_volar_takeover_mode
      and { 'vue', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
    or { 'vue' }
  local tsdk_path = node_util.get_typescript_server_path(node_root)

  return vim.tbl_extend('force', {}, {
    cmd = {
      'node',
      vim.cfg.lsp__vue_language_server,
      '--stdio',
    },
    filetypes = fts,
    commands = require('userlib.lsp.commands'),
    settings = M.settings,
    init_options = {
      vue = {
        hybridMode = true,
      },
      typescript = {
        tsdk = tsdk_path,
      },
    },
  })
end
