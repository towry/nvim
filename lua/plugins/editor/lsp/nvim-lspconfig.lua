local au = require('libs.runtime.au')

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

return {
  'neovim/nvim-lspconfig',
  name = 'lsp',
  event = au.user_autocmds.FileOpened,
  dependencies = {
    'jose-elias-alvarez/typescript.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'jose-elias-alvarez/null-ls.nvim',
    'williamboman/mason-lspconfig.nvim',
    'j-hui/fidget.nvim',
    'williamboman/mason.nvim',
  },
  config = function()
    local lspconfig = require('lspconfig')
    require('mason')
    require('mason-lspconfig').setup({
      ensure_installed = vim.cfg.lsp__auto_install_servers,
      automatic_installation = vim.cfg.lsp__automatic_installation,
    })
    local servers_path = "libs.lspconfig-servers."
    local handlers = require('libs.lspconfig.handlers')
    local capabilities = require('libs.lspconfig.capbilities')(require('cmp_nvim_lsp').default_capabilities())
    local lsp_flags = {
      debounce_text_changes = 600,
      allow_incremental_sync = false,
    }

    default_lspconfig_ui_options()
    -- loop over lsp__enable_servers list
    for _, server in ipairs(vim.cfg.lsp__enable_servers) do
      local load_ok, server_rc = pcall(require, servers_path .. server)
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

    au.do_usercmd(au.user_autocmds.LspConfigDone)
  end,
}
