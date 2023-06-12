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
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = {
        layout = "diff2_vertical",
        winbar_info = false,
      },
    },
    keymaps = {
      disable_defaults = false,
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
  },
  config = function(_, opts)
    require('diffview').setup(opts)
  end,
}
