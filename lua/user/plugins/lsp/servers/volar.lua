return function(opts)
  local node_root = vim.loop.cwd()
  local node_util = require('lua.user.runtime.platform.nodejs')

  local fts = vim.cfg.lsp__server_volar_takeover_mode and
  { 'vue', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } or { 'vue' }
  require('lspconfig').volar.setup(vim.tbl_extend('force', opts, {
    filetypes = fts,
    commands = require('user.plugins.lsp.commands'),
    init_options = {
      typescript = {
        tsdk = node_util.get_typescript_server_path(node_root),
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
