-- https://github.com/mrjones2014/dotfiles/blob/master/nvim/lua/my/configure/lspconfig.lua

local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')

local function default_lspconfig_ui_options()
  local present, win = pcall(require, 'lspconfig.ui.windows')
  if not present then
    return
  end
  win.default_options.border = vim.cfg.ui__float_border
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
    },
  },

  {
    'neovim/nvim-lspconfig',
    lazy = true,
    dependencies = {
      -- 'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason-lspconfig.nvim',
      'williamboman/mason.nvim',
      {
        'hrsh7th/nvim-gtd',
        config = true,
      },
      {
        'creativenull/efmls-configs-nvim',
        enabled = false,
      },
    },
    config = function()
      require('user.config.options').setup_lsp()
      require('mason')
      require('mason-lspconfig').setup({
        ensure_installed = vim.cfg.lsp__auto_install_servers,
        automatic_installation = vim.cfg.lsp__automatic_installation,
      })

      default_lspconfig_ui_options()

      au.do_useraucmd(au.user_autocmds.LspConfigDone_User)
      require('userlib.lsp.cfg.diagnostic').setup()
      require('userlib.lsp.cfg.inlayhints').setup({
        enabled = false,
        insert_only = false,
        highlight = 'NonText',
      })
    end,
    init = function()
      au.on_verylazy(require('userlib.lsp').setup)
      au.on_lsp_attach(function(client, bufnr)
        require('userlib.lsp.cfg.commands').setup_commands(client, bufnr)
        require('userlib.lsp.cfg.keymaps').setup_keybinding(client, bufnr)
        require('userlib.lsp.servers.null_ls.fmt').attach(client, bufnr)
      end)
    end,
  },

  {
    -- null-ls
    -- be sure to run ./scripts/install-web-dep.sh
    'nvimtools/none-ls.nvim',
    dev = false,
  },

  ---- lua
  {
    'mrjones2014/lua-gf.nvim',
    ft = 'lua',
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^3',
    ft = { 'rust' },
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    -- https://github.com/mrcjkb/rustaceanvim
    init = function()
      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {},
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            -- you can also put keymaps in here
          end,
          settings = {
            ['rust-analyzer'] = {
              cargo = {
                autoreload = true,
              },
              checkOnSave = {
                command = 'clippy',
              },
              inlayHints = {
                bindingModeHints = { enable = true },
                closureReturnTypeHints = { enable = true },
                lifetimeElisionHints = { enable = true },
                reborrowHints = { enable = true },
              },
              diagnostics = {
                disabled = { 'inactive-code', 'unresolved-proc-macro' },
              },
              procMacro = { enable = true },
              files = {
                excludeDirs = {
                  '.direnv',
                  'target',
                  'js',
                  'node_modules',
                  'assets',
                  'ci',
                  'data',
                  'docs',
                  'store-metadata',
                  '.gitlab',
                  '.vscode',
                  '.git',
                },
              },
              completion = {
                postfix = {
                  enable = false,
                },
              },
            },
          },
        },
        -- DAP configuration
        dap = {},
      }
    end,
    event = 'BufReadPre Cargo.toml,*.rs',
  },

  {
    'saecki/crates.nvim',
    event = 'BufRead Cargo.toml',
    opts = {
      popup = {
        autofocus = true,
        border = vim.cfg.ui__float_border,
      },
    },
  },

  {
    'Mofiqul/trld.nvim',
    event = 'LspAttach',
    enabled = false,
    opts = {
      -- bottom doesn't bottom enough.
      position = 'top',
      auto_cmds = true,
    },
  },
})
