local plug = require('libs.runtime.pack').plug

local header_static_str = [[
       _,    _   _    ,_
  .o888P     Y8o8Y     Y888o.
 d88888      88888      88888b
d888888b_  _d88888b_  _d888888b
8888888888888888888888888888888
8888888888888888888888888888888
YJGS8P"Y888P"Y888P"Y888P"Y8888P
 Y888   '8'   Y8P   '8'   888Y
  '8o          V          o8'
    `                     `
  ]]

plug({
  'goolord/alpha-nvim',
  enabled = false,
  cmd = { 'Alpha', 'AlphaRedraw' },
  opts = function()
    local dashboard = require("alpha.themes.dashboard")
    local Path = require('libs.runtime.path')
    local logo = {}
    local insert = table.insert
    for line in header_static_str:gmatch('[^\r\n]+') do
      insert(logo, line)
    end

    local icons = require('libs.icons')
    local header_bottom = {
      type = 'text',
      val = " : " .. Path.home_to_tilde(vim.loop.cwd()),
      opts = {
        position = 'center',
        hl = 'VirtualTextHint',
      },
    }
    dashboard.section.header.val = logo
    dashboard.section.buttons.val = {
      dashboard.button("/", icons.timer .. " Load session", '<cmd>SessionManager load_current_dir_session<CR>'),
      dashboard.button('r',
        icons.fileRecent .. ' ' .. 'Recents',
        '<cmd>lua require("libs.telescope.pickers").project_files({cwd_only=true,oldfiles=true})<cr>'),
      dashboard.button('f', icons.fileNoBg .. ' ' .. 'Find File',
        '<cmd>lua require("libs.telescope.pickers").project_files()<CR>'),
      dashboard.button('s', icons.t .. ' ' .. 'Search Content',
        '<cmd>lua require("libs.telescope.multi-rg-picker")()<CR>'),
      dashboard.button("l", "󰒲 " .. " Lazy", "<cmd>Lazy<CR>"),
      dashboard.button("q", icons.exit .. " Quit", "<cmd>qa<CR>"),
    }
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
    end
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"
    dashboard.opts.layout[1].val = 2
    table.insert(dashboard.opts.layout, 3, header_bottom)
    return dashboard
  end,
  config = function(_, dashboard)
    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        pattern = "AlphaReady",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    local update_extra_info = function()
      local lazy = require("lazy")
      local git = require('libs.git.utils')
      local stats = lazy.stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"

      local br = git.get_git_abbr_head() or 'Not git repo'

      dashboard.opts.layout[3].val = dashboard.opts.layout[3].val .. "   : " .. br
    end

    update_extra_info()
    require("alpha").setup(dashboard.opts)
  end,
  init = function()
    -- listen enter dashboard event.
    local au = require('libs.runtime.au')
    au.define_autocmds({
      {
        "User",
        {
          group = '_plugin_enter_dashboard',
          pattern = au.user_autocmds.DoEnterDashboard,
          callback = function()
            pcall(vim.cmd.Alpha)
          end,
        }
      }
    })
  end,
})
