local M = {}
function M.setup_keybinding(client, buffer)
  local keymap = require('userlib.runtime.keymap')
  local ms = require('vim.lsp.protocol').Methods
  local support = function(method)
    return Ty.client_support(client, method)
  end
  local opts = function(e)
    return vim.tbl_extend('force', {
      buffer = buffer,
    }, e or {})
  end
  local _ = function(d)
    return '' .. d
  end
  local set = keymap.set
  local cmdstr = keymap.cmdstr
  local func_call = function(call_sig)
    return cmdstr([[lua require("userlib.lsp.func").]] .. call_sig)
  end

  set(
    'n',
    ']dd',
    func_call('diagnostic_goto(true)'),
    opts({
      desc = _('Go to next diagnostic'),
      nowait = true,
    })
  )
  set(
    'n',
    '[dd',
    func_call('diagnostic_goto(false)'),
    opts({
      desc = _('Go to previous diagnostic'),
      nowait = true,
    })
  )
  set(
    'n',
    ']de',
    func_call("diagnostic_goto(true, 'ERROR')"),
    opts({
      desc = _('Go to next error diagnostic'),
      nowait = true,
    })
  )
  set(
    'n',
    '[de',
    func_call("diagnostic_goto(false, 'ERROR')"),
    opts({
      desc = _('Go to previous error diagnostic'),
      nowait = true,
    })
  )
  set(
    'n',
    ']dw',
    func_call("diagnostic_goto(true, 'WARN')"),
    opts({
      desc = _('Go to next warning diagnostic'),
      nowait = true,
    })
  )
  set(
    'n',
    '[dw',
    func_call("diagnostic_goto(false, 'WARN')"),
    opts({
      desc = _('Go to previous warning diagnostic'),
      nowait = true,
    })
  )
  set(
    'n',
    ']dh',
    func_call("diagnostic_goto(true, 'HINT')"),
    opts({
      desc = _('Go to next hint diagnostic'),
      nowait = true,
    })
  )
  set(
    'n',
    '[dh',
    func_call("diagnostic_goto(false, 'HINT')"),
    opts({
      desc = _('Go to previous hint diagnostic'),
      nowait = true,
    })
  )
  set(
    'n',
    '<leader>cld',
    ':lua vim.diagnostic.setloclist()<cr>',
    opts({
      desc = _('Diagnostics in location list'),
      nowait = true,
    })
  )
  set(
    'n',
    '<leader>ch',
    func_call('goto_code_references()'),
    opts({
      desc = _('find code references'),
    })
  )

  if support(ms.textDocument_declaration) then
    set('n', '<leader>ct', func_call('goto_declaration()'), opts({ desc = _('goto declaration') }))
  end

  if support(ms.workspace_symbol) then
    set('n', '<leader>cs', func_call('lsp_workspace_symbol()'), opts({ desc = _('search workspace symbols') }))
    set(
      'n',
      '<leader>cS',
      func_call([[lsp_workspace_symbol(vim.fn.expand("<cword>"))]]),
      opts({ desc = _('search workspace symbols') })
    )
  end

  -- Code actions.
  if support(ms.textDocument_codeAction) then
    set(
      'n',
      '<leader>co',
      cmdstr([[lua vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' }}, apply = true})]]),
      opts({
        desc = _('Organize Imports'),
      })
    )
    set(
      'n',
      '<leader>ci',
      cmdstr([[lua vim.lsp.buf.code_action({ context = { only = { 'source.addMissingImports' }}, apply = true})]]),
      opts({
        desc = _('Add import from ...'),
      })
    )
    set(
      { 'n', 'v' },
      '<leader>ca',
      cmdstr([[lua require('userlib.lsp.func').open_code_action()]]),
      opts({
        desc = _('Code Action'),
      })
    )
    set(
      { 'n', 'v' },
      '<leader>cA',
      func_call('open_code_action()'),
      opts({
        desc = _('Code Source Action'),
      })
    )
  end

  set('n', '<leader>tf', function()
    require('userlib.lsp.servers.null_ls.autoformat').toggle()
  end, {
    desc = 'Toggle auto format',
  })

  if support(ms.textDocument_rename) then
    set(
      'n',
      '<leader>cr',
      func_call('rename_name()'),
      opts({
        desc = _('Rename'),
      })
    )
  end

  set(
    { 'n', 'v', 'x' },
    '<leader>cf',
    func_call('format_code(0, { async = true })'),
    opts({
      desc = _('Format code'),
    })
  )
  set(
    'n',
    '<leader>cD',
    func_call('peek_type_definition()'),
    opts({
      desc = _('Peek type definition'),
    })
  )
  set(
    'n',
    '<leader>cd',
    func_call('peek_definition()'),
    opts({
      desc = _('Peek definition'),
    })
  )
  set(
    'n',
    '<leader>cm',
    func_call('show_signature_help()'),
    opts({
      desc = _('Show signature help'),
    })
  )

  -- gotos
  -- set('n', 'gd', func_call("goto_definition()"), opts({
  --   desc = _('Go to definition'),
  -- }))
  set(
    'n',
    'gy',
    func_call('goto_type_definition()'),
    opts({
      desc = _('Go to type definition'),
    })
  )
  set(
    'n',
    'gd',
    func_call('goto_definition_in_file()'),
    opts({
      desc = _('Go find definition in file'),
    })
  )
  set(
    'n',
    'gr',
    func_call('goto_code_references()'),
    opts({
      desc = _('Go find references'),
    })
  )
  set(
    'n',
    '<localleader>gds',
    func_call("goto_definition_in_file('split')"),
    opts({
      desc = _('Go find definition in file in split'),
    })
  )
  set(
    'n',
    '<localleader>gdv',
    func_call("goto_definition_in_file('vsplit')"),
    opts({
      desc = _('Go find definition in file in vsplit'),
    })
  )

  -- workspace.
  set(
    'n',
    '<leader>wa',
    cmdstr('lua vim.lsp.buf.add_workspace_folder()'),
    opts({
      desc = _('Add workspace folder'),
    })
  )
  set(
    'n',
    '<leader>wr',
    cmdstr('lua vim.lsp.buf.remove_workspace_folder()'),
    opts({
      desc = _('Remove workspace folder'),
    })
  )
  set(
    'n',
    '<leader>wl',
    function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end,
    opts({
      desc = _('List workspace folders'),
    })
  )
  set(
    'n',
    '<leader>wd',
    cmdstr('TroubleToggle workspace_diagnostics'),
    opts({
      desc = _('Toggle workspace diagnostics'),
    })
  )

  -- inline actions.
  set(
    'n',
    'KK',
    func_call('hover_action()'),
    opts({
      desc = _('Show hover or reveal UFO folding'),
      nowait = true,
    })
  )
  set(
    'n',
    'KL',
    func_call("show_diagnostics('line')"),
    opts({
      desc = _('Show diagnostics on current line'),
    })
  )
  set(
    'n',
    'KC',
    func_call("show_diagnostics('cursor')"),
    opts({
      desc = _('Show diagnostics at cursor'),
    })
  )
end

return M
