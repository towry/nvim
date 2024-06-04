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
  plugins = {
    -- NOTE: make make this module reuseable by the volar module
    -- with config 'volar#tsserver'.
    {
      name = '@vue/typescript-plugin',
      -- TODO: make it configurable
      location = vim.env.HOME .. '/.nix-profile/lib/node_modules/dotfiles/node_modules/@vue/typescript-plugin',
      languages = { 'javascript', 'typescript', 'vue' },
    },
  },
  preferences = {
    importModuleSpecifierPreference = 'relative',
    importModuleSpecifierEnding = 'index',
  },
}
M.filetypes = {
  'javascript',
  'typescript',
  'vue',
}

return M
