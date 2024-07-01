-- https://github.com/mrjones2014/dotfiles/blob/master/nvim/lua/my/configure/lspconfig.lua

local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')
local pathutil = require('userlib.runtime.path')

local masonInstallDir = pathutil.path_join(vim.fn.stdpath('data'), 'mason')

local function default_lspconfig_ui_options()
  local present, win = pcall(require, 'lspconfig.ui.windows')
  if not present then
    return
  end
  win.default_options.border = vim.cfg.ui__float_border
end

plug({
  {
    -- replace tsserver setup.
    -- 'pmizio/typescript-tools.nvim',
    'pze/typescript-tools.nvim',
    dev = false,
    enabled = false,
    config = function() end,
  },
  {
    'williamboman/mason.nvim',
    lazy = true,
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    cmd = { 'Mason', 'MasonInstall', 'MasonLog', 'MasonUpdate', 'MasonUninstall', 'MasonUninstallAll' },
    opts = {
      install_root_dir = masonInstallDir,
      PATH = 'skip',
      log_level = vim.log.levels.ERROR,
      ui = {
        border = vim.cfg.ui__float_border,
      },
    },
    init = function()
      local masonBinDir = pathutil.path_join(masonInstallDir, 'bin')
      vim.env.PATH = vim.env.PATH .. ':' .. masonBinDir
    end,
  },

  {
    'neovim/nvim-lspconfig',
    lazy = true,
    dependencies = {
      {
        --- bad performance
        'hrsh7th/nvim-gtd',
        config = true,
        enabled = false,
      },
      {
        'creativenull/efmls-configs-nvim',
        enabled = false,
      },
    },
    config = function()
      require('user.config.options').setup_lsp()
      if false then
        require('mason')
        require('mason-lspconfig').setup({
          ensure_installed = vim.cfg.lsp__auto_install_servers,
          automatic_installation = vim.cfg.lsp__automatic_installation,
        })
      end

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
      au.on_verylazy(function()
        require('userlib.lsp').setup()
      end)
      au.on_lsp_attach(function(client, bufnr)
        require('userlib.lsp.cfg.commands').setup_commands(client, bufnr)
        require('userlib.lsp.cfg.keymaps').setup_keybinding(client, bufnr)
        require('userlib.lsp.cfg.cmp').on_attach(client, bufnr)
        require('userlib.lsp.servers.null_ls.fmt').attach(client, bufnr)
        require('userlib.lsp.cfg.highlight').on_attach(client, bufnr)
      end)
    end,
  },

  {
    -- null-ls
    -- 'nvimtools/none-ls.nvim',
    'pze/none-ls.nvim',
    dependencies = {
      'nvimtools/none-ls-extras.nvim',
    },
    config = false,
    dev = false,
  },

  ---- lua
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    opts = {
      cmp = false,
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
        { path = 'wezterm-types', mods = { 'wezterm' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
  {
    'mrcjkb/rustaceanvim',
    version = '^4',
    ft = { 'rust' },
    cmd = { 'RustLsp' },
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-neotest/neotest',
      -- FIXME: not work
      -- {
      --   'nvim-neotest/neotest',
      --   optional = true,
      --   opts = function(_, opts)
      --     opts.adapters = opts.adapters or {}
      --     vim.list_extend(opts.adapters, {
      --       require('rustaceanvim.neotest'),
      --     })
      --     vim.print(opts)
      --     return opts
      --   end,
      -- },
    },
    -- https://github.com/mrcjkb/rustaceanvim
    init = function()
      vim.g.rustaceanvim = function()
        return {
          -- Plugin configuration
          tools = {},
          -- LSP configuration
          server = {
            on_attach = function(client, bufnr)
              vim.keymap.set('n', '<leader>ca', function()
                vim.cmd.RustLsp('codeAction')
              end, { silent = true, buffer = bufnr })
              vim.keymap.set('n', '<localleader>dl', function()
                vim.cmd.RustLsp('debuggables')
              end, { buffer = bufnr })
              vim.keymap.set('n', '<localleader>rl', function()
                vim.cmd.RustLsp('runnables')
              end, { buffer = bufnr })
            end,
            default_settings = {
              ['rust-analyzer'] = {
                cargo = {
                  loadOutDirsFromCheck = true,
                  runBuildScripts = true,
                },
                checkOnSave = {
                  enable = true,
                  command = 'clippy',
                  extraArgs = { '--no-deps', '--target-dir', 'target/check' },
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
                procMacro = {
                  enable = true,
                  ignored = {
                    ['async-trait'] = { 'async_trait' },
                    ['napi-derive'] = { 'napi' },
                    ['async-recursion'] = { 'async_recursion' },
                  },
                },
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
        }
      end
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
    'dgagn/diagflow.nvim',
    event = 'LspAttach',
    enabled = true,
    opts = {
      max_width = 50,
      max_height = 10,
      gap_size = 1,
      scope = 'line',
      text_align = 'right',
      toggle_event = { 'InsertEnter', 'InsertLeave' },
      placement = 'top',
      inline_padding_left = 1,
      show_sign = false,
      show_borders = false,
    },
  },

  {
    'rachartier/tiny-inline-diagnostic.nvim',
    enabled = false,
    event = 'LspAttach',
    config = function()
      require('tiny-inline-diagnostic').setup()
    end,
  },
})
