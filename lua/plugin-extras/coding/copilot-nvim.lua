return {
  {
    -- disable vim version.
    'github/copilot.vim',
    enabled = false,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = {
        enabled = true,
      },
      suggestion = {
        enabled = true,
      }
    },
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    opts = {
      event = { "InsertEnter", "LspAttach" },
      fix_pairs = true,
    },
    dependencies = {
      {
        'zbirenbaum/copilot.lua',
        opts = {
          panel = {
            enabled = false,
          },
          suggestion = {
            enabled = false,
          }
        }
      }
    },
    config = function(_, opts)
      require("copilot_cmp").setup(opts)
    end
  }
}
