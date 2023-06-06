return {
  config = function()
    require('diffview').setup({
      view = {
        default = {
          layout = "diff2_vertical",
          winbar_info = false,
        },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          local autocmd = require('libs.runtime.au')
          autocmd.fire_event(autocmd.events.onGitDiffviewBufRead, {
            bufnr = bufnr,
          })
        end,
        view_opened = function(view)
          local autocmd = require('libs.runtime.au')
          autocmd.fire_event(autocmd.events.onGitDiffviewOpen, {
            view = view,
          })
        end
      }
    })
  end,
}
