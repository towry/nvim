--- bind lsp keys.
return function(client, buffer)
  local keymap = require('ty.core.keymap')
  local n, v, nv, cmd, key = keymap.nmap, keymap.vmap, keymap.nv, keymap.cmd, keymap.key
  local cap = client.server_capabilities
  local opts = {
    buffer = buffer,
  }
  local _ = function(d) return '[LSP] ' .. d end

  -- diagnostic.
  n('<Plug>(motion-next-map)dd', _('Next Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(true)]], opts))
  n('<Plug>(motion-prev-map)dd', _('Prev Diagnostic'), cmd([[lua Ty.Func.navigate.diagnostic_goto(false)]], opts))
  n(
    '<Plug>(motion-next-map)de',
    _('Next Error Diagnostic'),
    cmd([[lua Ty.Func.navigate.diagnostic_goto(true, "ERROR")]], opts)
  )
  n(
    '<Plug>(motion-prev-map)de',
    _('Prev Error Diagnostic'),
    cmd([[lua Ty.Func.navigate.diagnostic_goto(false, "ERROR")]], opts)
  )
  n(
    '<Plug>(motion-next-map)dw',
    _('Next Warning Diagnostic'),
    cmd([[lua Ty.Func.navigate.diagnostic_goto(true, "WARN")]], opts)
  )
  n(
    '<Plug>(motion-prev-map)dw',
    _('Prev Warning Diagnostic'),
    cmd([[lua Ty.Func.navigate.diagnostic_goto(false, "WARN")]], opts)
  )
  n(
    '<Plug>(motion-next-map)dh',
    _('Next Hint Diagnostic'),
    cmd([[lua Ty.Func.navigate.diagnostic_goto(true, "HINT")]], opts)
  )
  n(
    '<Plug>(motion-prev-map)dh',
    _('Prev Hint Diagnostic'),
    cmd([[lua Ty.Func.navigate.diagnostic_goto(false, "HINT")]], opts)
  )

  n('<Plug>(leader-code-map)d', '[LSP] Go find code', cmd('lua Ty.Func.navigate.goto_code_references()', opts))

  if client.name == 'tsserver' then
    n(
      '<Plug>(leader-code-map)o',
      _('Organize Imports'),
      cmd([[lua require("typescript").actions.organizeImports()]], opts)
    )
    n('<Plug>(leader-code-map)R', _('Rename file'), cmd([[lua Ty.Func.editing.ts_rename_file()]], opts))
  end

  if cap.renameProvider then
    n('<Plug>(leader-code-map)r', _('Rename'), cmd([[lua Ty.Func.editing.rename_name()]], opts))
  end
  nv('<Plug>(leader-code-map)a', _('Code Action'), cmd([[lua Ty.Func.editing.open_code_action()]], opts))
  nv('<Plug>(leader-code-map)f', _('Format code'), cmd([[lua Ty.Func.editing.format_code()]], opts))
  n('<Plug>(leader-code-map)p', _('Peek definition'), cmd([[lua Ty.Func.editing.peek_definition()]], opts))

  -- goto.
  n('gfd<space>', 'Go find definition in file', cmd('lua Ty.Func.navigate.goto_definition_in_file()', opts))
  n('gfdx', 'Go find definition in file in split', cmd('lua Ty.Func.navigate.goto_definition_in_file("split")', opts))
  n('gfdv', 'Go find definition in file in vsplit', cmd('lua Ty.Func.navigate.goto_definition_in_file("vsplit")', opts))

  -- workspace.
  n('<leader>wa', _('add workspace folder'), key(vim.lsp.buf.add_workspace_folder, opts))
  n('<leader>wr', _('remove workspace folder'), key(vim.lsp.buf.remove_workspace_folder, opts))
  n(
    '<leader>wl',
    _('list workspace folders'),
    key(function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
  )

  -- inline actions.
  n('K', _('[LSP] Show hover or reveal UFO folding'), cmd('lua Ty.Func.editing.hover_action()', {
    '-nowait',
    buffer = buffer
  }))
  n('KS', _('[LSP] Show signature help'), cmd('lua Ty.Func.editing.show_signature_help()', opts))
  n('KL', _('[LSP] Show diagnostics on current line'), cmd('lua Ty.Func.editing.show_diagnostics("line")', opts))
  n('KC', _('[LSP] Show diagnostics at cursor'), cmd('lua Ty.Func.editing.show_diagnostics("cursor")', opts))
  n('KP', _('[LSP] Peek definition'), cmd([[lua Ty.Func.editing.peek_definition()]], opts))
  n('KT', _('[LSP] Peek type definition'), cmd([[lua Ty.Func.editing.peek_type_definition()]], opts))
end
