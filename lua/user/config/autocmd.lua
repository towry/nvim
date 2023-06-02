local au = require('user.runtime.au')

local M = {}

function M.load_on_startup()
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
            vim.api.nvim_del_augroup_by_name("_file_opened")
            vim.cmd("do " .. au.user_autocmds.FileOpened)
          end
        end,
      },
    },
    {
      "ColorScheme",
      group = "_colorscheme",
      callback = function()
        au.fire_event(au.events.AfterColorschemeChanged)
      end,
    },
    {
      'LspAttach',
      {
        group = '_lsp_attach_format',
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          au.fire_event(au.events.onLspAttach, {
            client = client,
            bufnr = bufnr,
          })
        end,
      }
    }
  }

  au.define_autocmds(definitions)
end

function M.setup_events_on_startup()
  au.register_event(au.events.onLspAttach, {
    name = "setup_formatter_on_buf",
    callback = function(args)
      require_plugin_spec('lsp.formatting').set_formatter(args.client, args.bufnr)
    end
  })
  au.register_event(au.events.onLspAttach, {
    name = "setup_autoformat_on_buf",
    callback = function(args)
      require_plugin_spec('lsp.formatting').set_autoformat_on_buf(args.client, args.bufnr)
    end,
  })
end

function M.setup()
  M.load_on_startup()
end

return M
