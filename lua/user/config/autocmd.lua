local au = require('libs.runtime.au')

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
            au.do_usercmd(au.user_autocmds.FileOpened)
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
        group = '_lsp_attach',
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

---resize kitty window, no padding when neovim is present.
local function resize_kitty()
  local kitty_aug = vim.api.nvim_create_augroup('kitty_aug', { clear = true })
  local resized = false
  vim.api.nvim_create_autocmd('User', {
    group = kitty_aug,
    pattern = 'DashboardDismiss',
    callback = function()
      vim.schedule(function()
        resized = true
        vim.cmd(':silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=0 margin=0')
      end)
    end,
  })
  vim.api.nvim_create_autocmd('UILeave', {
    group = kitty_aug,
    pattern = '*',
    callback = function()
      if not resized then return end
      vim.cmd(':silent !kitty @ --to=$KITTY_LISTEN_ON set-spacing padding=8 margin=0')
    end,
  })
end

---@param opts? {resize_kitty?: boolean}
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", {
    resize_kitty = false,
  }, opts or {})

  M.load_on_startup()
  if opts.resize_kitty then
    resize_kitty()
  end
end

return M
