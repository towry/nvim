local M = {}

M.cmd = {
  'node',
  vim.cfg.lsp__vtsls or 'vtsls',
  '--stdio',
}

--- https://raw.githubusercontent.com/yioneko/vtsls/main/packages/service/configuration.schema.json
local settings = {
  typescript = {
    tsserver = {
      maxTsServerMemory = 1500,
    },
    preferences = {
      importModuleSpecifierEnding = 'index',
      importModuleSpecifier = 'relative',
    },
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
    preferences = {
      importModuleSpecifierEnding = 'index',
      importModuleSpecifier = 'relative',
    },
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

  vtsls = {
    tsserver = {
      globalPlugins = {
        {
          name = '@vue/typescript-plugin',
          location = vim.cfg.lsp__vue_typescript_plugin,
          languages = { 'javascript', 'typescript', 'vue' },
        },
      },
    },
    autoUseWorkspaceTsdk = true,
    experimental = {
      completion = {
        --- Execute fuzzy match of completion items on server side. Enable this will help filter out useless completion items from tsserver.
        enableServerSideFuzzyMatch = true,
      },
    },
  },
}

M.settings = settings

return M
