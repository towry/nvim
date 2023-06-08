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
    init_options = {
      typescript = {
        tsdk = tsdk_path,
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      }
    }
  }))
end
