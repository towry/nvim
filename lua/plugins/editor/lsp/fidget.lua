local au = require('libs.runtime.au')

return {
  'j-hui/fidget.nvim',
  event = {
    au.user_autocmds.LspConfigDone,
  },
  enabled = vim.cfg.plugin__fidget_enable,
  config = function()
    require('fidget').setup({
      text = {
        spinner = 'pipe',
        done = '  ',
      },
      align = {
        bottom = true, -- align fidgets along bottom edge of buffer
        right = true,  -- align fidgets along right edge of buffer
      },
      window = {
        relative = 'editor',
        zindex = 100,
        border = 'rounded',
        blend = 0,
      },
      sources = {
        ['null-ls'] = {
          ignore = true,
        },
        ['tailwindcss'] = {
          ignore = true,
        },
      },
      timer = {
        spinner_rate = 60,
        -- how long to keep around empty fidget, in ms
        fidget_decay = 2000,
        -- how long to keep around completed task, in ms
        task_decay = 1000,
      },
      debug = {
        logging = false,
      },
    })
  end
}
