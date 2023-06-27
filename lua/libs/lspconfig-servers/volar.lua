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

return function(opts)
  local utils = require('libs.runtime.utils')
  local node_root = utils.get_root()
  local node_util = require('libs.runtime.platform.nodejs')

  local fts = vim.cfg.lsp__server_volar_takeover_mode and
      { 'vue', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } or { 'vue' }
  local tsdk_path = node_util.get_typescript_server_path(node_root)

  require('lspconfig').volar.setup(vim.tbl_extend('force', opts, {
    filetypes = fts,
    commands = require('libs.lsp-commands'),
    settings = M.settings,
    init_options = {
      typescript = {
        tsdk = tsdk_path,
      }
    }
  }))
end
