local set = require('userlib.runtime.keymap').map_buf_thunk(0)

return {
  attach = function()
    if vim.g.vscode then
      return
    end
    -- https://github.com/chrisgrieser/.config/blob/main/nvim/after/ftplugin/css.lua
    -- toggle !important (useful for debugging selectors)
    set('n', '<localleader>ti', function()
      local line = vim.api.nvim_get_current_line()
      if line:find('!important') then
        line = line:gsub(' !important', '')
      else
        line = line:gsub(';?$', ' !important;', 1)
      end
      vim.api.nvim_set_current_line(line)
    end, { desc = ' Toggle !important', nowait = true })
  end,
}
