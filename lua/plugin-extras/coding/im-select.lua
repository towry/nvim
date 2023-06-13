local plug = require('libs.runtime.pack').plug

return plug({
  {
    'keaising/im-select.nvim',
    event = { 'InsertEnter', 'CmdlineEnter', 'InsertLeave', },
    enabled = function()
      return vim.fn.executable('im-select')
    end,
    config = function()
      require('im_select').setup({
        default_im_select = "com.apple.keylayout.ABC",
        default_command = "im-select",
        keep_quiet_on_no_binary = true,
      })
    end,
  }
})
