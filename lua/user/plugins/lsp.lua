-- https://github.com/mrjones2014/dotfiles/blob/master/nvim/lua/my/configure/lspconfig.lua

local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')

local function default_lspconfig_ui_options()
  local present, win = pcall(require, 'lspconfig.ui.windows')
  if not present then return end
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
    event = { 'BufRead', 'BufNewFile' },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason-lspconfig.nvim',
      'williamboman/mason.nvim',
      {
        'hrsh7th/nvim-gtd',
        config = true,
      },
      {
        'creativenull/efmls-configs-nvim',
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
      local servers_path = 'userlib.lsp.servers.'
      local handlers = require('userlib.lsp.cfg.handlers')
      local capabilities = require('userlib.lsp.cfg.capbilities')(require('cmp_nvim_lsp').default_capabilities())
      local lsp_flags = {
        debounce_text_changes = 600,
        allow_incremental_sync = false,
      }
      local efm_setup_done = false

      default_lspconfig_ui_options()

      local function setup_lsp_for_filetype(filetype, server)
        -- setup efmls if not done already
        if not efm_setup_done and require('userlib.lsp.filetypes').uses_efm(filetype) then
          efm_setup_done = true
          require('lspconfig').efm.setup(require('userlib.lsp.filetypes').efmls_config(capabilities))
        end

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

      local function current_buf_matches_file_patterns(patterns)
        local bufname = vim.api.nvim_buf_get_name(0)
        for _, pattern in ipairs(patterns) do
          if string.match(bufname, string.format('.%s', pattern)) then return true end
        end

        return require('userlib.lsp.filetypes').uses_efm(vim.bo.ft)
      end

      local function setup_server(filetype, file_patterns, server_name)
        -- since we're lazy loading lspconfig itself,
        -- check if we need to start LSP immediately or not
        if current_buf_matches_file_patterns(file_patterns) then
          setup_lsp_for_filetype(filetype, server_name)
        else
          -- if not, set up an autocmd to lazy load the rest
          vim.api.nvim_create_autocmd('BufReadPre', {
            callback = function() setup_lsp_for_filetype(filetype, server_name) end,
            pattern = file_patterns,
            once = true,
          })
        end
      end

      for filetype, filetype_config in pairs(require('userlib.lsp.filetypes').config) do
        if not filetype_config.ignore then
          local file_patterns = filetype_config.patterns or { string.format('*.%s', filetype) }
          local server_name = filetype_config.lspconfig
          if file_patterns and server_name then
            if type(server_name) == 'table' then
              for _, server in ipairs(server_name) do
                setup_server(filetype, file_patterns, server)
              end
            else
              setup_server(filetype, file_patterns, server_name)
            end
          end
        end
      end

      au.do_useraucmd(au.user_autocmds.LspConfigDone_User)
      require('userlib.lsp.cfg.diagnostic').setup()
      require('userlib.lsp.cfg.inlayhints').setup({
        enabled = false,
        insert_only = true,
      })
    end,
    init = function()
      au.on_lsp_attach(function(client, bufnr)
        require('userlib.lsp.cfg.keymaps').setup_keybinding(client, bufnr)
        require('userlib.lsp.fmt').on_attach(client, bufnr)
      end)
    end,
  },

  ---- formats
  {
    'jose-elias-alvarez/null-ls.nvim',
  },

  ---- lua
  {
    'mrjones2014/lua-gf.nvim',
    ft = 'lua',
  },
  {
    'simrat39/rust-tools.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    config = function()
      local opts = {
        tools = {
          executor = require('rust-tools/executors').termopen,
          -- These apply to the default RustSetInlayHints command
          inlay_hints = {
            auto = true,
            show_parameter_hints = true,
            parameter_hints_prefix = '<- ',
            other_hints_prefix = '=> ',
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
          -- on_attach = on_lsp_attach,
        }, -- rust-analyer options
      }

      require('rust-tools').setup(opts)
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
    opts = {
      position = 'top',
      auto_cmds = true,
    },
  },
})
