return {
  {
    -- Convenience file operations for neovim, written in lua.
    "chrisgrieser/nvim-genghis",
    init = function()
      local au = require('libs.runtime.au')
      au.define_user_autocmd({
        pattern = au.user_autocmds.LegendaryConfigDone,
        callback = function()
          local lg = require('legendary')
          local genghis = require('genghis')

          lg.funcs({
            {
              description = 'File: Copy file path',
              genghis.copyFilepath,
            },
            {
              description = 'File: Change file mode',
              genghis.chmodx,
            },
            {
              description = 'File: Rename file',
              genghis.renameFile,
            },
            {
              description = 'File: Move and rename file',
              genghis.moveAndRenameFile,
            },
            {
              description = 'File: Create new file',
              genghis.createNewFile,
            },
            {
              description = 'File: Duplicate file',
              genghis.duplicateFile,
            },
            {
              description = 'File: Trash file',
              function()
                genghis.trashFile()
              end,
            },
            {
              description = 'File: Move selection to new file',
              genghis.moveSelectionToNewFile,
            }
          })
        end,
      })
    end
  }
}
