local au = require('libs.runtime.au')

return {
  {
    'kwkarlwang/bufresize.nvim',
    config = true,
  },
  {
    'echasnovski/mini.bufremove',
    keys = {
      {
        '<S-q>',
        function()
          require('mini.bufremove').delete(0)
          vim.schedule(function()
            if #require('libs.runtime.buffer').list_bufnrs() <= 0 then
              local cur_empty = require('libs.runtime.buffer').get_current_empty_buffer()
              -- start_dashboard()
              if cur_empty then
                vim.api.nvim_buf_delete(cur_empty, { force = true })
              end
            end
          end)
        end,
        desc = 'Quit current buffer',
      }
    }
  },

  --- open buffer last place.
  {
    'ethanholz/nvim-lastplace',
    event = au.user_autocmds.FileOpened_User,
    opts = {
      lastplace_ignore_buftype = { 'quickfix', 'nofile', 'help', 'alpha', 'NvimTree' },
      lastplace_ignore_filetype = { 'spectre_panel', 'gitcommit', 'gitrebase', 'svn', 'hgcommit' },
      lastplace_open_folds = true,
    }
  },

  --- auto close buffer after a time.
  {
    'chrisgrieser/nvim-early-retirement',
    config = function()
      require('early-retirement').setup({
        retirementAgeMins = 15,
        ignoreAltFile = true,
        minimumBufferNum = 10,
        ignoreUnsavedChangesBufs = true,
        ignoreSpecialBuftypes = true,
        ignoreVisibleBufs = true,
        ignoreUnloadedBufs = false,
        notificationOnAutoClose = true,
      })
    end,
    init = function()
      local loaded = false
      au.define_autocmds({
        {
          "User",
          {
            group = "_plugin_load_early_retirement",
            pattern = au.user_autocmds.FileOpened,
            once = true,
            callback = function()
              if loaded then
                return
              end
              loaded = true
              vim.defer_fn(function()
                vim.cmd("Lazy load nvim-early-retirement")
              end, 2000)
            end,
          }
        }
      })
    end,
  }
}
