return {
  'nvim-pack/nvim-spectre',
  opts = {
    color_devicons = true,
    open_cmd = 'vnew',
    live_update = true,
    is_insert_mode = false,
    is_open_target_win = false,
  },
  keys = {
    {
      '<leader>sp',
      function()
        require('spectre').open_visual()
      end,
      desc = 'Open Search and replace panel',
    },
    {
      '<leader>sP',
      function()
        local path = vim.fn.fnameescape(vim.fn.expand('%:p:.'))
        if vim.loop.os_uname().sysname == 'Windows_NT' then path = vim.fn.substitute(path, '\\', '/', 'g') end
        require('spectre').open({
          path = path,
          is_close = true,
          search_text = vim.fn.expand('<cword>'),
        })
      end,
      desc = 'Search and replace cword in current file'
    }
  }
}
