local M = {}

local lsp_flags = {
  debounce_text_changes = 600,
  allow_incremental_sync = false,
}

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

function M.config()
  local lspconfig = require('lspconfig')

  require('mason')
  require('mason-lspconfig').setup({
    ensure_installed = vim.cfg.lsp__auto_install_servers,
    automatic_installation = vim.cfg.lsp__automatic_installation,
  })

  if vim.cfg.plugin__fidget_enable then
    setup_fidget()
  end
  require('user.plugins.lsp.diagnostics').setup()
  default_lspconfig_ui_options()

  local handlers = require('libs.lspconfig.handlers')
  local capabilities = require('libs.lspconfig.capbilities')(require('cmp_nvim_lsp').default_capabilities())

  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  capabilities.workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    }
  }

  -- loop over lsp__enable_servers list
  for _, server in ipairs(vim.cfg.lsp__enable_servers) do
    local load_ok, server_rc = pcall(require, 'user.plugins.lsp.servers.' .. server)
    if type(server_rc) == 'function' then
      server_rc({
        flags = lsp_flags,
        capabilities = capabilities,
        handlers = handlers,
      })
    elseif load_ok then
      lspconfig[server].setup(vim.tbl_extend('force', {
        flags = lsp_flags,
        capabilities = capabilities,
        handlers = handlers,
      }, server_rc))
    else
      lspconfig[server].setup({
        flags = lsp_flags,
        capabilities,
        handlers,
      })
    end
  end
end

return M
