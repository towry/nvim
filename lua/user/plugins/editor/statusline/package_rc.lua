local M = {}

M.setup_lualine = require('ty.contrib.statusline.lualine').setup

M.setup_incline = function()
  if vim.g.started_by_firenvim then return end

  require('incline').setup({
    hide = {
      cursorline = true,
      focused_win = true,
      only_win = true,
    },
    window = {
      margin = {
        vertical = 0,
        horizontal = 0,
      },
    },
    render = function(props)
      -- local bufid = props.buf
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
      local icon, color = require('nvim-web-devicons').get_icon_color(filename)
      return {
        -- { '[' .. bufid .. '] ' },
        { icon .. ' ', guifg = color },
        { filename },
      }
    end,
  })
end

return M
