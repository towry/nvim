local au = require('user.runtime.au')

local M = {}

M.load_on_startup() 
  local definitions = {
     -- taken from AstroNvim
     -- Emit `User FileOpened` event, used by the plugins.
    {
      { "BufRead", "BufWinEnter", "BufNewFile" },
      {
        group = "_file_opened",
        nested = true,
        callback = function(args)
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
          if not (vim.fn.expand "%" == "" or buftype == "nofile") then
            vim.api.nvim_del_augroup_by_name "_file_opened"
            vim.cmd "do User FileOpened"
            require("lvim.lsp").setup()
          end
        end,
      },
    }
  }

  au.define_autocmds(definitions)
end

function M.setup()
  M.load_on_startup()
end

return M 