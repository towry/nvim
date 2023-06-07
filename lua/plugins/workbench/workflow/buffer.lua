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
  }
}
