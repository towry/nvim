local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')


local function default_lspconfig_ui_options()
  local present, win = pcall(require, 'lspconfig.ui.windows')
  if not present then return end

  local _default_opts = win.default_opts
  win.default_opts = function(options)
    local opts = _default_opts(options)
    opts.border = vim.cfg.ui__float_border
    return opts
  end
end

plug({
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonLog', 'MasonUpdate', 'MasonUninstall', 'MasonUninstallAll' },
    opts = {
      PATH = 'prepend',
      ui = {
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = vim.cfg.ui__float_border,
      },
    }
  },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = {
      'jose-elias-alvarez/typescript.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'jose-elias-alvarez/null-ls.nvim',
      'williamboman/mason-lspconfig.nvim',
      'williamboman/mason.nvim',
      {
        'hrsh7th/nvim-gtd',
        config = true,
      },
    },
    config = function()
      local lspconfig = require('lspconfig')
      require('user.config.options').setup_lsp()
      require('mason')
      require('mason-lspconfig').setup({
        ensure_installed = vim.cfg.lsp__auto_install_servers,
        automatic_installation = vim.cfg.lsp__automatic_installation,
      })
      local servers_path = "userlib.lspconfig-servers."
      local handlers = require('userlib.lspconfig.handlers')
      local capabilities = require('userlib.lspconfig.capbilities')(require('cmp_nvim_lsp').default_capabilities())
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

      au.do_useraucmd(au.user_autocmds.LspConfigDone_User)
      require('userlib.lspconfig.diagnostic').setup()
      require('userlib.lspconfig.inlayhints').setup({
        enabled = false,
        insert_only = true,
      })
    end,
    init = function()
      au.on_lsp_attach(function(client, bufnr)
        require('userlib.lspconfig.keymaps').setup_keybinding(client, bufnr)
      end)
    end,
  },

  ---- formats
  {
    'jose-elias-alvarez/null-ls.nvim',
  },
  {
    'pze/lsp-format.nvim',
    enabled = false,
    opts = {
      sync = true,
    },
  },

  ---- lua
  {
    'mrjones2014/lua-gf.nvim',
    ft = 'lua'
  },
  {
    'folke/neodev.nvim',
  },
  {
    'simrat39/rust-tools.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    config = function()
      local opts = {
        tools = {
          executor = require("rust-tools/executors").termopen,
          -- These apply to the default RustSetInlayHints command
          inlay_hints = {
            auto = true,
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
            max_len_align = false,
            max_len_align_padding = 1,
            right_align = false,
            right_align_padding = 7,
          },
          hover_actions = {
            auto_focus = true,
          },
        },
        -- send our rust-analyzer configuration to lspconfig
        server = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                autoreload = true,
              },
              checkOnSave = {
                command = "clippy",
              },
              completion = {
                postfix = {
                  enable = false,
                },
              },
            }
          },
          -- on_attach = on_lsp_attach,
        }, -- rust-analyer options
      }

      require("rust-tools").setup(opts)
    end,
    event = 'BufReadPre Cargo.toml,*.rs',
  },

  {
    'saecki/crates.nvim',
    event = 'BufRead Cargo.toml',
    opts = {
      popup = {
        autofocus = true,
        border = "single",
      },
    }
  }

})
