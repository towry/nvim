return {
  'simrat39/rust-tools.nvim',
  dependencies = {
    'neovim/nvim-lspconfig',
  },
  ft = { 'rust', 'toml' },
  config = function()
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
  end,
}
