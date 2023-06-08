return {
  'sindrets/diffview.nvim',
  keys = {
    { '<leader>gD', '<cmd>lua require("libs.git.utils").toggle_file_history()<cr>',    desc = 'Git file history' },
    { '<leader>gd', '<cmd>lua require("libs.git.utils").toggle_working_changes()<cr>', desc = 'Git changes' },
  },
  cmd = {
    'DiffviewLog',
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewRefresh',
    'DiffviewFocusFile',
    'DiffviewFileHistory',
    'DiffviewToggleFiles',
  },
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
