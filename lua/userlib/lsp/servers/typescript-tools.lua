local settings = {
  separate_diagnostic_server = true,
  publish_diagnostic_on = 'insert_leave',
  tsserver_file_preferences = {
    includeInlayParameterNameHints = 'all',
    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayVariableTypeHints = false,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = false,
    includeInlayEnumMemberValueHints = true,
  },
  tsserver_format_options = {
    allowIncompleteCompletions = false,
    allowRenameOfImportPath = false,
  },
}

local on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  vim.schedule(function()
    local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)
    set('n', '<leader>cO', ':TSToolsOrganizeImports<cr>', {
      desc = 'Sorts and removes used imports',
    })
    set('n', '<leader>co', ':TSToolsSortImports<cr>', {
      desc = 'Sorts imports',
    })
    set('n', '<leader>ci', ':TSToolsAddMissingImports<cr>', {
      desc = 'Add missing imports',
    })
  end)
end

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

local M = {}

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
M.autostart = false

local lspconfig_done = false
local config_name = 'typescript-tools'

return function(opts)
  if not lspconfig_done then
    local plugin_config = require('typescript-tools.config')
    local lspconfig_configs = require('lspconfig.configs')
    local rpc = require('typescript-tools.rpc')
    local util = require('lspconfig.util')

    plugin_config.load_settings(M.settings)
    if lspconfig_configs[config_name] == nil then
      lspconfig_configs[config_name] = {
        default_config = {
          cmd = function(...)
            return rpc.start(...)
          end,
          filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
          },
          root_dir = function(fname)
            -- INFO: stealed from:
            -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/tsserver.lua#L22
            local root_dir = util.root_pattern('tsconfig.json')(fname)
              or util.root_pattern('package.json', 'jsconfig.json', '.git')(fname)

            -- INFO: this is needed to make sure we don't pick up root_dir inside node_modules
            local node_modules_index = root_dir and root_dir:find('node_modules', 1, true)
            if node_modules_index and node_modules_index > 0 then
              root_dir = root_dir:sub(1, node_modules_index - 2)
            end

            return root_dir
          end,
          single_file_support = true,
        },
      }
    end
    lspconfig_done = true
  end

  return vim.tbl_extend('force', opts or {}, M)
end
