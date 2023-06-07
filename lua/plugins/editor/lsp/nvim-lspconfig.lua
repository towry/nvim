local au = require('libs.runtime.au')
local keymap = require('libs.runtime.keymap')

local function setup_keybinding(client, buffer)
  local cap = client.server_capabilities
  local opts = function(e)
    return vim.tbl_extend('force', {
      buffer = buffer,
    }, e or {})
  end
  local _ = function(d) return ' ' .. d end
  local set = keymap.set
  local cmdstr = keymap.cmdstr
  local func_call = function(call_sig) return cmdstr([[lua require("plugins.editor.lsp.utils.func").]] .. call_sig) end
  -----
  set('n', ']dd', func_call("diagnostic_goto(true)"), opts({
    desc = _('Go to next diagnostic'),
    nowait = true,
  }))
  set('n', '[dd', func_call("diagnostic_goto(false)"), opts({
    desc = _('Go to previous diagnostic'),
    nowait = true,
  }))
  set('n', ']de', func_call("diagnostic_goto(true, 'ERROR')"), opts({
    desc = _('Go to next error diagnostic'),
    nowait = true,
  }))
  set('n', '[de', func_call("diagnostic_goto(false, 'ERROR')"), opts({
    desc = _('Go to previous error diagnostic'),
    nowait = true,
  }))
  set('n', ']dw', func_call("diagnostic_goto(true, 'WARN')"), opts({
    desc = _('Go to next warning diagnostic'),
    nowait = true,
  }))
  set('n', '[dw', func_call("diagnostic_goto(false, 'WARN')"), opts({
    desc = _('Go to previous warning diagnostic'),
    nowait = true,
  }))
  set('n', ']dh', func_call("diagnostic_goto(true, 'HINT')"), opts({
    desc = _('Go to next hint diagnostic'),
    nowait = true,
  }))
  set('n', '[dh', func_call("diagnostic_goto(false, 'HINT')"), opts({
    desc = _('Go to previous hint diagnostic'),
    nowait = true,
  }))
  set('n', '<leader>ch', func_call("goto_code_references()"), opts({
    desc = _('find code references'),
  }))

  -- Code actions.
  if cap.codeActionProvider then
    set('n', '<leader>cA', cmdstr([[lua vim.lsp.buf.code_action({ context = { only = { "source" }}})]], opts({
      desc = _('Source Action'),
    })))
    set('n', '<leader>co',
      cmdstr([[lua vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' }}, apply = true})]], opts({
        desc = _('Organize Imports'),
      })))
    set({ 'n', 'v' }, '<leader>ca', func_call("open_code_action()"),
      opts({
        desc = _('Code Action'),
      }))
    -- <CMD-.> on kitty
    set('n', '<Char-0xAD>', func_call("open_code_action()"),
      opts({
        desc = _('Code Action'),
      }))
  end

  -- TS Server specific.
  if client.name == 'tsserver' then
    set('n', '<leader>co', cmdstr([[lua require("typescript").actions.organizeImports()]]), opts({
      desc = _('Organize Imports'),
    }))
    set('n', '<leader>cR', func_call("ts_rename_file()"), opts({
      desc = _('Rename file'),
    }))
  end
  -- if cap.renameProvider then n('<leader>cr', _('Rename'), cmd([[lua Ty.Func.editing.rename_name()]], opts)) end
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

return {
  'neovim/nvim-lspconfig',
  name = 'lsp',
  event = au.user_autocmds.FileOpened_User,
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

    au.do_useraucmd(au.user_autocmds.LspConfigDone_User)
  end,
  init = function()
    au.on_lsp_attach(function(client, bufnr)
      setup_keybinding(client, bufnr)
    end)
  end,
}
