--- bind lsp keys.
return function(client, buffer)
  local keymap = require('ty.core.keymap')
  local n, nv, cmd, key = keymap.nmap, keymap.nv, keymap.cmd, keymap.key
  local cap = client.server_capabilities
  local opts = {
    buffer = buffer,
  }
  local opts_nowait = {
    buffer = buffer,
    '+nowait',
  }
  local _ = function(d) return ' ' .. d end

  -- diagnostic.
  n(']d', 'Next Diagnostic')
  n('[d', 'Prev Diagnostic')
  n(']dd', _('Next Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(true)]], opts_nowait))
  n('[dd', _('Prev Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(false)]], opts_nowait))
  n(']de', _('Next Error Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(true, "ERROR")]], opts_nowait))
  n('[de', _('Prev Error Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(false, "ERROR")]], opts_nowait))
  n(']dw', _('Next Warning Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(true, "WARN")]], opts_nowait))
  n('[dw', _('Prev Warning Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(false, "WARN")]], opts_nowait))
  n(']dh', _('Next Hint Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(true, "HINT")]], opts_nowait))
  n('[dh', _('Prev Hint Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(false, "HINT")]], opts_nowait))

  ---code maps.
  n('<leader>c', 'Code')
  n('<leader>cd', _('Toggle document diagnostics'), cmd('TroubleToggle document_diagnostics'))
  n('<leader>ch', _('find code references'), cmd('lua Ty.Func.navigate.goto_code_references()', opts))

  if cap.codeActionProvider then
    n('<leader>cA', _('Source Action'), cmd([[lua vim.lsp.buf.code_action({ context = { only = { "source" }}})]], opts))
    n('<leader>co', _('Organize Imports'),
      cmd([[lua vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' }}, apply = true})]], opts))
    nv('<leader>ca', _('Code Action'), cmd([[lua Ty.Func.editing.open_code_action()]], opts))
    -- <CMD-.> on kitty
    n('<Char-0xAD>', _('Code Action'), cmd([[lua Ty.Func.editing.open_code_action()]], opts))
  end

  if client.name == 'tsserver' then
    n('<leader>co', _('Organize Imports'), cmd([[lua require("typescript").actions.organizeImports()]], opts))
    n('<leader>cR', _('Rename file'), cmd([[lua Ty.Func.editing.ts_rename_file()]], opts))
  end
  if cap.renameProvider then n('<leader>cr', _('Rename'), cmd([[lua Ty.Func.editing.rename_name()]], opts)) end
  nv('<leader>cf', _('Format code'), cmd([[lua Ty.Func.editing.format_code(0, { async = true })]], opts))
  n('<leader>ct', _('Peek type definition'), cmd('lua Ty.Func.editing.peek_type_definition()'))
  n('<leader>cp', _('Peek definition'), cmd([[lua Ty.Func.editing.peek_definition()]], opts))
  n('<leader>cm', _('Show signature help'), cmd('lua Ty.Func.editing.show_signature_help()', opts))

  -- goto.
  n('gd', _('Go to definition'), cmd('lua Ty.Func.navigate.goto_definition()', {
    buffer = buffer,
    "+group"
  }))
  n('gt', '[LSP] Go to type definition', cmd('lua Ty.Func.navigate.goto_type_definition()'))
  n('gdf', '[LSP] Go find definition in file')
  n(
    'gdfx',
    '[LSP] Go find definition in file in split',
    cmd('lua Ty.Func.navigate.goto_definition_in_file("split")', opts)
  )
  n(
    'gdfv',
    '[LSP] Go find definition in file in vsplit',
    cmd('lua Ty.Func.navigate.goto_definition_in_file("vsplit")', opts)
  )

  -- workspace.
  n("<leader>w", "Workspace")
  n('<leader>wa', _('add workspace folder'), key(vim.lsp.buf.add_workspace_folder, opts))
  n('<leader>wr', _('remove workspace folder'), key(vim.lsp.buf.remove_workspace_folder, opts))
  n(
    '<leader>wl',
    _('list workspace folders'),
    key(function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
  )
  n('<leader>wd', _('toggle workspace diagnostics'), cmd('TroubleToggle workspace_diagnostics'))

  -- inline actions.
  n(
    'KK',
    _('Show hover or reveal UFO folding'),
    cmd('lua Ty.Func.editing.hover_action()', {
      '+nowait',
      buffer = buffer,
    })
  )
  n('KL', _('Show diagnostics on current line'), cmd('lua Ty.Func.editing.show_diagnostics("line")', opts))
  n('KC', _('Show diagnostics at cursor'), cmd('lua Ty.Func.editing.show_diagnostics("cursor")', opts))
  -- require('which-key').reset();
end
