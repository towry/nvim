local node_util = require('ty.core.node')
local M = {}
-- ============================================

local lsp_flags = {
  debounce_text_changes = 600,
  allow_incremental_sync = false,
}

local volar_takeover_mode = true
local auto_servers = { 'bashls', 'html', 'prismals' }

-- TODO: on setup lspconfig prev.
local function setup_fidget()
  require('fidget').setup({
    text = {
      spinner = 'pipe',
      done = '  ',
    },
    align = {
      bottom = true, -- align fidgets along bottom edge of buffer
      right = true,  -- align fidgets along right edge of buffer
    },
    window = {
      relative = 'editor',
      zindex = 100,
      border = 'rounded',
      blend = 0,
    },
    sources = {
      ['null-ls'] = {
        ignore = true,
      },
      ['tailwindcss'] = {
        ignore = true,
      },
    },
    timer = {
      spinner_rate = 60,
      -- how long to keep around empty fidget, in ms
      fidget_decay = 2000,
      -- how long to keep around completed task, in ms
      task_decay = 1000,
    },
    debug = {
      logging = false,
    },
  })
end

local function setup_typescript()
  local typescript_ok, typescript = pcall(require, 'typescript')
  if not typescript_ok then return end
  local tsserver_rc = require('ty.contrib.editing.lsp.servers.tsserver')

  typescript.setup({
    disable_commands = false, -- prevent the plugin from creating Vim commands
    debug = false,            -- enable debug logging for commands
    -- LSP Config options
    server = {
      capabilities = tsserver_rc.capabilities,
      handlers = tsserver_rc.handlers,
      on_attach = function(client, bufnr) tsserver_rc.on_attach(client, bufnr) end,
      settings = tsserver_rc.settings,
      flags = lsp_flags,
    },
  })
end

local function default_lspconfig_ui_options()
  local present, win = pcall(require, 'lspconfig.ui.windows')
  if not present then return end

  local _default_opts = win.default_opts
  win.default_opts = function(options)
    local opts = _default_opts(options)
    opts.border = Ty.Config.ui.float.border
    return opts
  end
end

function M.setup()
  -- local lspconfig_util = require('lspconfig.util')
  local lspconfig = require('lspconfig')

  require('mason')
  require('mason-lspconfig').setup({
    ensure_installed = {
      'bashls',
      'cssls',
      'eslint',
      'html',
      'jsonls',
      'lua_ls',
      'tailwindcss',
      'tsserver',
      'volar',
      'prismals',
    },
    automatic_installation = true,
  })

  setup_fidget()
  require('ty.contrib.editing.lsp.diagnostics').setup()
  default_lspconfig_ui_options()

  if not volar_takeover_mode then
    setup_typescript()
  end

  local handlers = {
    ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = Ty.Config.ui.float.border }),
    ['textDocument/signatureHelp'] = vim.lsp.with(
      vim.lsp.handlers.signature_help,
      { border = Ty.Config.ui.float.border }
    ),
    -- ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics),
  }

  ---@diagnostic disable-next-line: unused-local
  local function on_attach(_client, _bufnr)
    -- set up buffer keymaps, etc.
    -- buffer keys is set at `ty.contrib.editing.init`
  end

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  capabilities.workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    }
  }

  local tailwindcss_rc = require('ty.contrib.editing.lsp.servers.tailwindcss')
  -- may causing input in jsx very slow.
  lspconfig.tailwindcss.setup({
    -- cmd = node_util.get_mason_node_cmd({
    --   cmd_name = 'tailwindcss-language-server',
    --   node_path = 'tsx',
    --   args = {
    --     '--stdio',
    --   }
    -- }),
    capabilities = tailwindcss_rc.capabilities,
    filetypes = tailwindcss_rc.filetypes,
    handlers = handlers,
    init_options = tailwindcss_rc.init_options,
    on_attach = tailwindcss_rc.on_attach,
    settings = tailwindcss_rc.settings,
    flags = {
      debounce_text_changes = 2500,
    },
  })

  lspconfig.cssls.setup({
    capabilities = capabilities,
    handlers = handlers,
    on_attach = require('ty.contrib.editing.lsp.servers.cssls').on_attach,
    settings = require('ty.contrib.editing.lsp.servers.cssls').settings,
  })


  lspconfig.jsonls.setup({
    capabilities = capabilities,
    handlers = handlers,
    on_attach = on_attach,
    settings = require('ty.contrib.editing.lsp.servers.jsonls').settings,
  })

  if require('ty.core.utils').has_plugin('neodev.nvim') then
    require('neodev').setup({
      setup_jsonls = false,
      lspconfig = false,
      library = {
        plugins = { 'nvim-treesitter', 'plenary.nvim', 'telescope.nvim', 'nvim-luadev' },
      },
    })
  end
  lspconfig.lua_ls.setup({
    before_init = require('neodev.lsp').before_init,
    capabilities = capabilities,
    handlers = handlers,
    on_attach = on_attach,
    settings = require('ty.contrib.editing.lsp.servers.lua_ls').settings,
  })
  local node_root = vim.loop.cwd()
  lspconfig.volar.setup({
    filetypes = not volar_takeover_mode and { 'vue' } or
        { 'vue', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    capabilities = capabilities,
    handlers = handlers,
    on_attach = on_attach,
    commands = require('ty.contrib.editing.lsp.commands'),
    init_options = {
      typescript = {
        tsdk = node_util.get_typescript_server_path(node_root),
      }
    }
  })

  -- lspconfig.vuels.setup {
  --   filetypes = require('ty.contrib.editing.lsp.servers.vuels').filetypes,
  --   handlers = handlers,
  --   init_options = require('ty.contrib.editing.lsp.servers.vuels').init_options,
  --   on_attach = on_attach,
  -- }

  for _, server in ipairs(auto_servers) do
    lspconfig[server].setup({
      on_attach = on_attach,
      capabilities = capabilities,
      handlers = handlers,
      flags = lsp_flags,
    })
  end

  require('ty.contrib.editing.lsp.null-ls').setup({
    on_attach = on_attach,
  })
end

return M
