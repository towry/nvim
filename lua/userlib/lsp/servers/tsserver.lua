local M = {}

local capabilities = require('userlib.lsp.cfg.capbilities')()
capabilities.textDocument.codeAction = {
  dynamicRegistration = false,
  codeActionLiteralSupport = {
    codeActionKind = {
      valueSet = {
        '',
        'quickfix',
        'refactor',
        'refactor.extract',
        'refactor.inline',
        'refactor.rewrite',
        'source',
        'source.organizeImports',
      },
    },
  },
}
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

local on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

local settings = {
  typescript = {
    inlayHints = {
      includeInlayParameterNameHints = 'all',
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = false,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = false,
      includeInlayEnumMemberValueHints = true,
    },
  },
  javascript = {
    inlayHints = {
      includeInlayParameterNameHints = 'all',
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = false,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = false,
      includeInlayEnumMemberValueHints = true,
    },
  },
}

M.capabilities = capabilities
M.on_attach = on_attach
M.settings = settings
--- https://github.com/typescript-language-server/typescript-language-server#initializationoptions
M.init_options = {
  preferences = {
    importModuleSpecifierPreference = 'relative',
    importModuleSpecifierEnding = 'index',
  },
}

return function(opts)
  if vim.cfg.lsp__server_volar_takeover_mode then return end
  require('lspconfig').tsserver.setup(vim.tbl_extend('force', opts, M))
end
