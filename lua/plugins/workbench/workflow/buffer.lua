local au = require('libs.runtime.au')

return {
  {
    'echasnovski/mini.bufremove',
    keys = {
      {
        '<S-q>',
        function()
          require('mini.bufremove').delete(0)
          vim.schedule(function()
            if #require('ty.core.buffer').list_bufnrs() <= 0 then
              local cur_empty = require('ty.core.buffer').get_current_empty_buffer()
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
  }
}
