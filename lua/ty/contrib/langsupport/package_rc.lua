local config = require('ty.core.config').langsupport
local M = {}

M.setup_treesitter = require('ty.contrib.langsupport.treesitter').setup
M.setup_rust = function()
  local opts = {
    tools = {
      executor = require("rust-tools/executors").termopen,

      -- These apply to the default RustSetInlayHints command
      inlay_hints = {
        auto = true,
        show_parameter_hints = true,
        parameter_hints_prefix = "<- ",
        other_hints_prefix = "=> ",
        max_len_align = false,
        max_len_align_padding = 1,
        right_align = false,
        right_align_padding = 7,
      },

      hover_actions = {
        auto_focus = true,
      },
    },
    -- send our rust-analyzer configuration to lspconfig
    server = {
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            autoreload = true,
          },
          checkOnSave = {
            command = "clippy",
          },
          completion = {
            postfix = {
              enable = false,
            },
          },
        }
      },
      -- on_attach = on_lsp_attach,
    }, -- rust-analyer options
  }

  require("rust-tools").setup(opts)
  require("lspconfig")["rust_analyzer"].manager.try_add()
end
M.setup_package_info = function()
  local icons = require('ty.contrib.ui.icons')
  require('package-info').setup({
    colors = {
      up_to_date = '#3C4048', -- Text color for up to date package virtual text
      outdated = '#fc514e', -- Text color for outdated package virtual text
    },
    icons = {
      enable = true, -- Whether to display icons
      style = {
        up_to_date = icons.checkSquare, -- Icon for up to date packages
        outdated = icons.gitRemove, -- Icon for outdated packages
      },
    },
    autostart = true, -- Whether to autostart when `package.json` is opened
    hide_up_to_date = true, -- It hides up to date versions when displaying virtual text
    hide_unstable_versions = true, -- It hides unstable versions from version list e.g next-11.1.3-canary3
    -- Can be `npm` or `yarn`. Used for `delete`, `install` etc...
    -- The plugin will try to auto-detect the package manager based on
    -- `yarn.lock` or `package-lock.json`. If none are found it will use the
    -- provided one,                              if nothing is provided it will use `yarn`
    package_manager = 'yarn',
  })
end

M.option_colorizer = {
  filetypes = config.colorizer.filetypes,
  user_default_options = {
    mode = 'background',
    tailwind = config.colorizer.enable_tailwind_color, -- Enable tailwind colors
  },
}
M.option_hlargs = {
  color = '#F7768E',
}
-- M.option_template_string = {
--   filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'python' },
--   jsx_brackets = true,
-- }

return M
