local au = require('libs.runtime.au')

local M = {}

function M.load_on_startup()
  local current_timeoutlen = vim.opt.timeoutlen:get() or 400

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
            au.do_useraucmd(au.user_autocmds.FileOpened_User)

            vim.defer_fn(function()
              au.do_useraucmd(au.user_autocmds.FileOpenedAfter_User)
            end, 30)
          end
        end,
      },
    },
    {
      "ColorScheme",
      {
        group = "_colorscheme",
        callback = function()
          au.fire_event(au.events.AfterColorschemeChanged)
        end,
      }
    },
    {
      'LspAttach',
      {
        group = '_lsp_attach_event',
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          au.fire_event(au.events.onLspAttach, {
            client = client,
            bufnr = bufnr,
          })
        end,
      }
    },
    -- show cursor line only in active window
    {
      { "InsertLeave", "WinEnter" },
      {
        group = '_cursorline_active_window',
        callback = function()
          local ok, cl = pcall(vim.api.nvim_win_get_var, 0, "auto-cursorline")
          if ok and cl then
            vim.wo.cursorline = true
            vim.api.nvim_win_del_var(0, "auto-cursorline")
          end
        end
      }
    },
    {
      { "InsertEnter", "WinLeave" },
      {
        group = '_cursorline_active_window',
        callback = function()
          local cl = vim.wo.cursorline
          if cl then
            vim.api.nvim_win_set_var(0, "auto-cursorline", cl)
            vim.wo.cursorline = false
          end
        end
      }
    },
    {
      { 'BufRead', 'BufNewFile' },
      {
        group = '_no_lsp_diagnostic_inside_folders',
        pattern = '*/node_modules/*',
        command = 'lua vim.diagnostic.disable(0)',
      }
    },
    ------------------------------------
    {
      { 'InsertEnter' },
      {
        group = 'no_insert_delay',
        callback = function()
          vim.opt.timeoutlen = 0
        end
      }
    },
    {
      { 'InsertLeave' },
      {
        group = 'no_insert_delay',
        callback = function()
          vim.opt.timeoutlen = current_timeoutlen
        end
      }
    },
  }
  local user_definitions = {
    {
      pattern = "AlphaClosed",
      callback = function()
        au.do_useraucmd(au.user_autocmds.OnLeaveDashboard_User)
      end
    }
  }

  au.define_autocmds(definitions)
  au.define_user_autocmds(user_definitions)
end

function M.setup_events_on_startup()
  au.register_event(au.events.onLspAttach, {
    name = "setup_formatter_on_buf",
    callback = function(args)
      require('libs.lsp-format').choose_formatter_for_buf(args.client, args.bufnr)
      require('libs.lsp-format.autoformat').attach(args.client, args.bufnr)
      local is_auto_format_enable_config = true
      if is_auto_format_enable_config then
        require('libs.lsp-format.autoformat').enable()
      end
    end
  })
end

---resize kitty window, no padding when neovim is present.
local function resize_kitty()
  local kitty_aug = vim.api.nvim_create_augroup('kitty_aug', { clear = true })
  local resized = false
  vim.api.nvim_create_autocmd({ 'UIEnter' }, {
    group = kitty_aug,
    pattern = '*',
    callback = function()
      if resized then return end
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
  M.setup_events_on_startup()

  if opts.resize_kitty then
    resize_kitty()
  end
end

return M
