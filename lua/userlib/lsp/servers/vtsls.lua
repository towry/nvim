local M = {}

M.cmd = {
  vim.cfg.lsp__vtsls or 'vtsls',
  '--stdio',
}

--- https://raw.githubusercontent.com/yioneko/vtsls/main/packages/service/configuration.schema.json
local settings = {
  typescript = {
    tsserver = {
      -- log = 'verbose',
      maxTsServerMemory = 1800,
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
        ------ this will cause duplicate diagnostic in ts files.
        ---- but without this, vtsls will raise some error
        {
          name = '@vue/typescript-plugin',
          location = vim.cfg.lsp__vue_typescript_plugin,
          languages = { 'vue' },
          configNamespace = 'typescript',
          enableForWorkspaceTypeScriptVersions = true,
        },
      },
    },

    -- autoUseWorkspaceTsdk = true, --- this option cause it not working in some
    -- project
    experimental = {
      completion = {
        --- Execute fuzzy match of completion items on server side. Enable this will help filter out useless completion items from tsserver.
        enableServerSideFuzzyMatch = false,
      },
    },
  },
}

M.settings = settings

M.filetypes = {
  'javascript',
  'typescript',
  'javascriptreact',
  'typescriptreact',
  'vue',
}

return M
