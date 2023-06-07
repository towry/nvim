-- spectre_panel ft.
--
local au = require('libs.runtime.au')

au.define_autcmds({
  {
    'BufferEnter',
    {
      group = 'spectre_keys',
      buffer = '<buffer>',
      callback = function(ctx)
        -- TODO: fixme
        -- require('ty.contrib.keymaps.attach.spectre').on_buffer_enter(ctx)
      end
    }
  }
})
