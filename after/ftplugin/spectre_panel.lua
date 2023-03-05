-- spectre_panel ft.
--
require('ty.core.autocmd').with_group('spectre_keys'):create('BufferEnter', {
  buffer = '<buffer>',
  callback = function(ctx) require('ty.contrib.keymaps.attach.spectre').on_buffer_enter(ctx) end,
})
